package room

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"

	dockerMount "github.com/docker/docker/api/types/mount"

	"github.com/m1k1o/neko-rooms/internal/types"
)

var labelRegex = regexp.MustCompile(`^[a-z0-9.-]+$`)

type RoomLabels struct {
	Name         string
	URL          string
	Mux          bool
	Epr          EprPorts
	Port         uint16
	StatsEnabled bool

	NekoImage  string
	ApiVersion int

	BrowserPolicy *BrowserPolicyLabels
	UserDefined   map[string]string
}

type BrowserPolicyLabels struct {
	Type types.BrowserPolicyType
	Path string
}

func (manager *RoomManagerCtx) extractLabels(labels map[string]string) (*RoomLabels, error) {
	name, ok := labels["m1k1o.neko_rooms.name"]
	if !ok {
		return nil, fmt.Errorf("damaged container labels: name not found")
	}

	url, ok := labels["m1k1o.neko_rooms.url"]
	if !ok {
		// TODO: It should be always available.
		url = manager.config.GetRoomUrl(name)
		//return nil, fmt.Errorf("damaged container labels: url not found")
	}

	var mux bool
	var epr EprPorts

	muxStr, ok := labels["m1k1o.neko_rooms.mux"]
	if ok {
		muxPort, err := strconv.ParseUint(muxStr, 10, 16)
		if err != nil {
			return nil, err
		}

		mux = true
		epr = EprPorts{
			Min: uint16(muxPort),
			Max: uint16(muxPort),
		}
	} else {
		eprMinStr, ok := labels["m1k1o.neko_rooms.epr.min"]
		if !ok {
			return nil, fmt.Errorf("damaged container labels: epr.min not found")
		}

		eprMin, err := strconv.ParseUint(eprMinStr, 10, 16)
		if err != nil {
			return nil, err
		}

		eprMaxStr, ok := labels["m1k1o.neko_rooms.epr.max"]
		if !ok {
			return nil, fmt.Errorf("damaged container labels: epr.max not found")
		}

		eprMax, err := strconv.ParseUint(eprMaxStr, 10, 16)
		if err != nil {
			return nil, err
		}

		mux = false
		epr = EprPorts{
			Min: uint16(eprMin),
			Max: uint16(eprMax),
		}
	}

	nekoImage, ok := labels["m1k1o.neko_rooms.neko_image"]
	if !ok {
		return nil, fmt.Errorf("damaged container labels: neko_image not found")
	}

	frontendPort, err := frontendPortFromLabels(labels)
	if err != nil {
		return nil, err
	}

	statsEnabled, err := statsEnabledFromLabels(labels)
	if err != nil {
		return nil, err
	}

	apiVersion := 2 // default, prior to api versioning
	apiVersionStr, ok := labels["m1k1o.neko_rooms.api_version"]
	if ok {
		apiVersion, err = strconv.Atoi(apiVersionStr)
		if err != nil {
			return nil, err
		}
	}

	var browserPolicy *BrowserPolicyLabels
	if val, ok := labels["m1k1o.neko_rooms.browser_policy"]; ok && val == "true" {
		policyType, ok := labels["m1k1o.neko_rooms.browser_policy.type"]
		if !ok {
			return nil, fmt.Errorf("damaged container labels: browser_policy.type not found")
		}

		policyPath, ok := labels["m1k1o.neko_rooms.browser_policy.path"]
		if !ok {
			return nil, fmt.Errorf("damaged container labels: browser_policy.path not found")
		}

		browserPolicy = &BrowserPolicyLabels{
			Type: types.BrowserPolicyType(policyType),
			Path: policyPath,
		}
	}

	// extract user defined labels
	userDefined := map[string]string{}
	for key, val := range labels {
		if after, ok := strings.CutPrefix(key, "m1k1o.neko_rooms.x-"); ok {
			userDefined[after] = val
		}
	}

	return &RoomLabels{
		Name:         name,
		URL:          url,
		Mux:          mux,
		Epr:          epr,
		Port:         frontendPort,
		StatsEnabled: statsEnabled,

		NekoImage:  nekoImage,
		ApiVersion: apiVersion,

		BrowserPolicy: browserPolicy,
		UserDefined:   userDefined,
	}, nil
}

func (manager *RoomManagerCtx) serializeLabels(labels RoomLabels) map[string]string {
	labelsMap := map[string]string{
		"m1k1o.neko_rooms.name":       labels.Name,
		"m1k1o.neko_rooms.url":        manager.config.GetRoomUrl(labels.Name),
		"m1k1o.neko_rooms.instance":   manager.config.InstanceName,
		"m1k1o.neko_rooms.neko_image": labels.NekoImage,
	}

	// api version 2 is currently default
	if labels.ApiVersion != 2 {
		labelsMap["m1k1o.neko_rooms.api_version"] = fmt.Sprintf("%d", labels.ApiVersion)
	}

	if labels.Mux && labels.Epr.Min == labels.Epr.Max {
		labelsMap["m1k1o.neko_rooms.mux"] = fmt.Sprintf("%d", labels.Epr.Min)
	} else {
		labelsMap["m1k1o.neko_rooms.epr.min"] = fmt.Sprintf("%d", labels.Epr.Min)
		labelsMap["m1k1o.neko_rooms.epr.max"] = fmt.Sprintf("%d", labels.Epr.Max)
	}

	if labels.Port != 0 && labels.Port != defaultFrontendPort {
		labelsMap["m1k1o.neko_rooms.frontend_port"] = fmt.Sprintf("%d", labels.Port)
	}

	if !labels.StatsEnabled {
		labelsMap["m1k1o.neko_rooms.stats"] = "false"
	}

	if labels.BrowserPolicy != nil {
		labelsMap["m1k1o.neko_rooms.browser_policy"] = "true"
		labelsMap["m1k1o.neko_rooms.browser_policy.type"] = string(labels.BrowserPolicy.Type)
		labelsMap["m1k1o.neko_rooms.browser_policy.path"] = labels.BrowserPolicy.Path
	}

	for key, val := range labels.UserDefined {
		// to lowercase
		key = strings.ToLower(key)

		labelsMap[fmt.Sprintf("m1k1o.neko_rooms.x-%s", key)] = val
	}

	return labelsMap
}

func CheckLabelKey(name string) bool {
	return labelRegex.MatchString(name)
}

func frontendPortFromLabels(labels map[string]string) (uint16, error) {
	val, ok := labels["m1k1o.neko_rooms.frontend_port"]
	if !ok || val == "" {
		return defaultFrontendPort, nil
	}

	port, err := strconv.ParseUint(val, 10, 16)
	if err != nil {
		return 0, fmt.Errorf("invalid frontend_port label: %w", err)
	}
	if port == 0 {
		return 0, fmt.Errorf("invalid frontend_port label: must be greater than 0")
	}

	return uint16(port), nil
}

func statsEnabledFromLabels(labels map[string]string) (bool, error) {
	val, ok := labels["m1k1o.neko_rooms.stats"]
	if !ok || val == "" {
		if image, ok := labels["m1k1o.neko_rooms.neko_image"]; ok && strings.Contains(strings.ToLower(image), "windows") {
			return false, nil
		}
		return true, nil
	}

	enabled, err := strconv.ParseBool(val)
	if err != nil {
		return false, fmt.Errorf("invalid stats label: %w", err)
	}

	return enabled, nil
}

func bindMountsFromLabels(labels map[string]string) ([]dockerMount.Mount, error) {
	val, ok := labels["m1k1o.neko_rooms.bind_mounts"]
	if !ok || val == "" {
		return nil, nil
	}

	mounts := []dockerMount.Mount{}
	for _, item := range strings.Split(val, ",") {
		parts := strings.Split(item, ":")
		if len(parts) != 2 {
			return nil, fmt.Errorf("invalid bind_mounts label item %q", item)
		}

		source := strings.TrimSpace(parts[0])
		target := strings.TrimSpace(parts[1])
		if source == "" || target == "" {
			return nil, fmt.Errorf("invalid bind_mounts label item %q", item)
		}

		mounts = append(mounts, dockerMount.Mount{
			Type:        dockerMount.TypeBind,
			Source:      source,
			Target:      target,
			Consistency: dockerMount.ConsistencyDefault,
			BindOptions: &dockerMount.BindOptions{
				Propagation:  dockerMount.PropagationRPrivate,
				NonRecursive: false,
			},
		})
	}

	return mounts, nil
}
