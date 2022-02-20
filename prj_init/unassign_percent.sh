tail -n +2 total_read_counts.tsv | cut -f2 | paste -sd+ | bc | awk -F '\t' 'NR==FNR {str=$0; next}; END{print $2/str*100"% Percent Unassigned"}' - total_read_counts.tsv
