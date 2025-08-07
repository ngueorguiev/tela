#
# library for common network functions used in different resources
#

# Get network address
#
function calc_ipv4_netaddr() {
        local ip="$1"
        local prefix="$2"
        local i1 i2 i3 i4               # IP octet parts
        local mask m1 m2 m3 m4          # subnet mask as integer and its octets
        local nw_addr nw1 nw2 nw3 nw4   # final network address and its octets

        # Split IP into its octets
        IFS=. read -r i1 i2 i3 i4 <<< "$ip"

        # Calculate subnet mask
        #   - 0xffffffff represents the integer value with all bits set to 1
        #   - << (32 - $prefix) shifts this value to the left,
        #     leaving prefix "ones" and 32 - prefix "zeros"
        #   - & 0xffffffff ensures value with 32 bit
        mask=$(( (0xffffffff << (32 - $prefix)) & 0xffffffff ))

        # Write subnet masks octets into m# variables by shifting the subnet
        # mask bits accordingly
        IFS=. read -r m1 m2 m3 m4 <<< "$(
            printf "%d.%d.%d.%d\n" \
            $(( (mask >> 24) )) \
            $(( (mask >> 16) & 0xff )) \
            $(( (mask >> 8) & 0xff )) \
            $(( mask & 0xff ))
        )"

        # Perform bitwise AND between each IP octets (i1–i4) and the
        # corresponding mask octet (m1–m4). This clears all bits in the IP that
        # are outside the network prefix, resulting in the network octets.
        nw1=$(( i1 & m1 ))
        nw2=$(( i2 & m2 ))
        nw3=$(( i3 & m3 ))
        nw4=$(( i4 & m4 ))

        nw_addr="$nw1.$nw2.$nw3.$nw4"

        echo "$nw_addr"
}

# Get IP address, prefix length and network address from net device
# See get_ip() from src/libexec/resources/system
function check_netdev_ip() {
        local netdev="$1" line
        local ipv4_addr ipv4_prefix ipv4_nw_addr

        IFS_BAK=$IFS
        IFS=$' \t\n'

        while read -r line ; do
                set -- $line
                if [[ "$1" == "inet" ]]; then
                        ipv4_addr="${2%%/*}"
                        ipv4_prefix="${2##*/}"
                        ipv4_nw_addr=$(calc_ipv4_netaddr "$ipv4_addr" "$ipv4_prefix")
                        echo "    ipv4:"
                        echo "      addr: ${ipv4_addr}"
                        echo "      prefix: ${ipv4_prefix}"
                        echo "      netaddr: ${ipv4_nw_addr}"
                elif [[ "$1" == "inet6" ]]; then
                        echo "    ipv6:"
                        echo "      addr: ${2%%/*}"
                        echo "      prefix: ${2##*/}"
                fi
        done < <(ip addr show dev "$netdev")

        IFS=$IFS_BAK
}
