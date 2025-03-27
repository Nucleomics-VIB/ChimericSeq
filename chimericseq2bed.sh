#!/bin/bash

# Convert chimericseq csv output to BED-like format
# Usage: ./chimericseq2bed.sh input.csv output.bed
# SP@NC; 2025-03-27; v1.0

# current bed_columns:
#   [chrom, host_start, host_end, gene, viral_acc, viral_start, viral_end, vmapq]
# rem: can be tuned to extract other columns out of this complete list
#   ReadName,ReadLength,Sequence,Chromosome,Gene,InsideGene,DistanceToGene,GeneDirection,
#   Focus,GeneObj,FocusObj,HostLocalCords,Hlength,HostRefCords,HostOrientation,
#   ViralAccession,ViralLocalCords,Vlength,ViralRefCords,ViralOrientation,
#   HTM,HTMAdjusted,VTM,VTMAdjusted,Overlap,OverlapTM,OverlapTMAdjusted,
#   Inserted,Microhomology,HostMapFlag,ViralMapFlag,HMapQ,VMapQ,FastqSource,Index,

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.csv output.bed"
    exit 1
fi

input_file="$1"
output_file="$2"

python3 - <<'EOF' "$input_file" "$output_file"
import csv
import sys
import re

def natural_key(s):
    # Return a list of string and number chunks for natural sorting.
    return [int(text) if text.isdigit() else text.lower() for text in re.split('([0-9]+)', s)]

if len(sys.argv) != 3:
    print("Usage: {} input.csv output.bed".format(sys.argv[0]))
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

bed_lines = []

with open(input_file, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        # Skip comment or header lines
        if row['ReadName'].strip().startswith("//"):
            continue

        # Extract host coordinates from HostRefCords (e.g., "[57909181, 57909290]")
        host_ref = row.get('HostRefCords', '').strip()
        m = re.search(r'\[(\d+),\s*(\d+)\]', host_ref)
        if m:
            host_start, host_end = m.groups()
        else:
            host_start, host_end = "0", "0"

        chrom = row.get('Chromosome', 'chrN').strip()
        gene = row.get('Gene', 'NA').strip()

        # Extract viral insertion info
        viral_acc = row.get('ViralAccession', 'NA').strip()
        viral_ref = row.get('ViralRefCords', '').strip()
        m2 = re.search(r'\[(\d+),\s*(\d+)\]', viral_ref)
        if m2:
            viral_start, viral_end = m2.groups()
        else:
            viral_start, viral_end = "NA", "NA"

        # Use VMapQ as a proxy for coverage depth
        vmapq = row.get('VMapQ', 'NA').strip()

        # Append gene field; output order:
        # chrom, host_start, host_end, gene, viral_acc, viral_start, viral_end, vmapq
        bed_lines.append([chrom, host_start, host_end, gene, viral_acc, viral_start, viral_end, vmapq])

# Sort the bed_lines by chromosome (natural order) then numeric order of start and end
sorted_lines = sorted(bed_lines, key=lambda x: (natural_key(x[0]), int(x[1]), int(x[2])))

with open(output_file, 'w', newline='') as bedfile:
    writer = csv.writer(bedfile, delimiter='\t')
    for line in sorted_lines:
        writer.writerow(line)
EOF