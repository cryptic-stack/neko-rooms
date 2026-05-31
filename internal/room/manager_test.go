package room

import (
	"reflect"
	"testing"
)

func TestUniqueStrings(t *testing.T) {
	got := uniqueStrings("lab-a", "hacklab-lab-a", "lab-a", "", "custom-host")
	want := []string{"lab-a", "hacklab-lab-a", "custom-host"}

	if !reflect.DeepEqual(got, want) {
		t.Fatalf("expected %#v, got %#v", want, got)
	}
}
