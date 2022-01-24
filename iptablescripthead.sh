workdir="/etc/lanloginserver"
intln=$(yq e '.Interfaces' $workdir/config.yaml | wc -l)
declare -A myips
declare -A myips6
for i in $(seq 0 1 $(($intln-1)))
do
        interfaces[$i]=$(yq e ".Interfaces[$i]" $workdir/config.yaml)
        allip=$(ip a show ${interfaces[$i]} | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        for k in $(seq 0 1 $(($(echo "$allip" | wc -l)-1)))
        do
                myips[$i,$k]=$(echo "$allip" | sed -n $((${k}+1))p | awk '$1=$1')
        done
        allip6=$(ip a show ${interfaces[$i]} | grep -oP '(?<=inet6\s)[a-z0-9:]*' | grep -v '^fe80')
        for k in $(seq 0 1 $(($(echo "$allip6" | wc -l)-1)))
        do
                myips6[$i,$k]=$(echo "$allip6" | sed -n $((${k}+1))p | awk '$1=$1')
        done
done