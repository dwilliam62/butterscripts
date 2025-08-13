#!/bin/bash
# stock_yahoo_simple_changes.sh

get_yahoo_price() {
    local symbol=$1
    local display_name=${symbol//\^/}
    
    data=$(curl -s -H "User-Agent: Mozilla/5.0" \
        "https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d&range=1d" 2>/dev/null)
    
    if [[ -n "$data" ]]; then
        price=$(echo "$data" | jq -r '.chart.result[0].meta.regularMarketPrice // empty' 2>/dev/null)
        prev_close=$(echo "$data" | jq -r '.chart.result[0].meta.previousClose // empty' 2>/dev/null)
        
        if [[ -n "$price" ]] && [[ "$price" != "null" ]] && [[ -n "$prev_close" ]] && [[ "$prev_close" != "null" ]]; then
            # Calculate percent change using awk
            pct_change=$(echo "$price $prev_close" | awk '{printf "%+.2f", (($1 - $2) / $2) * 100}')
            printf "%s: \$%.2f (%s%%)" "$display_name" "$price" "$pct_change"
        else
            printf "%s: N/A" "$display_name"
        fi
    else
        printf "%s: N/A" "$display_name"
    fi
}

symbols=("AAPL" "NVDA" "^GSPC" "AMD" "^IXIC" "^DJI")
output=""

for symbol in "${symbols[@]}"; do
    if [[ -n "$output" ]]; then
        output="$output | "
    fi
    output="$output$(get_yahoo_price "$symbol")"
    sleep 1
done

echo "$output"
