package room

import "testing"

func TestFrontendPortFromLabelsDefault(t *testing.T) {
	port, err := frontendPortFromLabels(map[string]string{})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if port != defaultFrontendPort {
		t.Fatalf("expected default port %d, got %d", defaultFrontendPort, port)
	}
}

func TestFrontendPortFromLabelsCustom(t *testing.T) {
	port, err := frontendPortFromLabels(map[string]string{
		"m1k1o.neko_rooms.frontend_port": "8006",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if port != 8006 {
		t.Fatalf("expected port 8006, got %d", port)
	}
}

func TestFrontendPortFromLabelsInvalid(t *testing.T) {
	if _, err := frontendPortFromLabels(map[string]string{
		"m1k1o.neko_rooms.frontend_port": "0",
	}); err == nil {
		t.Fatal("expected error")
	}
}

func TestStatsEnabledFromLabelsDefaultsToTrue(t *testing.T) {
	enabled, err := statsEnabledFromLabels(map[string]string{})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !enabled {
		t.Fatal("expected stats to be enabled by default")
	}
}

func TestStatsEnabledFromLabelsFalse(t *testing.T) {
	enabled, err := statsEnabledFromLabels(map[string]string{
		"m1k1o.neko_rooms.stats": "false",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if enabled {
		t.Fatal("expected stats to be disabled")
	}
}

func TestBindMountsFromLabels(t *testing.T) {
	mounts, err := bindMountsFromLabels(map[string]string{
		"m1k1o.neko_rooms.bind_mounts": "/dev/kvm:/dev/kvm,/dev/net/tun:/dev/net/tun",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(mounts) != 2 {
		t.Fatalf("expected 2 mounts, got %d", len(mounts))
	}
	if mounts[0].Source != "/dev/kvm" || mounts[0].Target != "/dev/kvm" {
		t.Fatalf("unexpected first mount: %#v", mounts[0])
	}
}
