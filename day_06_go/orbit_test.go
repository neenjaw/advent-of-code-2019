package orbit

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"testing"
)

func TestParseOrbitA(t *testing.T) {
	testOrbitFile("orbit_a", t)
	testOrbitFile("orbit_b", t)
}

func testOrbitFile(file string, t *testing.T) {
	orbitPairs, err := readOrbitFile(file)
	if err != nil {
		t.Error(err.Error())
	}

	var g Graph
	for _, orbitPair := range orbitPairs {
		a, b := orbitPair[0], orbitPair[1]
		g.AddNode(&a)
		g.AddNode(&b)
		g.AddUnidirectionalEdge(&a, &b)
	}

	origin := Body("COM")
	checksum := g.CalcChecksum(&origin)

	fmt.Print(g.String())
	fmt.Printf("Checksum %v\n", checksum)
}

func readOrbitFile(path string) ([][]Body, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var pairs [][]Body
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		strpair := strings.Split(scanner.Text(), ")")

		var pair []Body
		pair = append(pair, Body(strpair[0]), Body(strpair[1]))
		pairs = append(pairs, pair)
	}
	return pairs, scanner.Err()
}
