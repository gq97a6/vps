#!/bin/bash

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to add port forwarding rules
add_forwarding() {
    echo -e "${BLUE}=== Add Port Forwarding ===${NC}"
    read -p "Enter the internal IP address (e.g., 10.1.0.2): " internal_ip
    read -p "Enter the port number: " port
    
    # Validate IP address format
    if ! [[ $internal_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo -e "${RED}Error: Invalid IP address format${NC}"
        return 1
    fi
    
    # Validate port number
    if ! [[ $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
        echo -e "${RED}Error: Invalid port number (must be 1-65535)${NC}"
        return 1
    fi
    
    # Check if rule already exists
    if iptables -t nat -C PREROUTING -p tcp --dport $port -j DNAT --to-destination $internal_ip:$port 2>/dev/null; then
        echo -e "${YELLOW}Warning: Rule for port $port already exists${NC}"
        read -p "Do you want to replace it? (y/n): " replace
        if [[ $replace != "y" ]]; then
            return 1
        fi
        # Remove existing rules first
        remove_forwarding_silent $port
    fi
    
    echo -e "${YELLOW}Adding forwarding rules for $internal_ip:$port...${NC}"
    
    # Add NAT rules
    iptables -t nat -A PREROUTING -p tcp --dport $port -j DNAT --to-destination $internal_ip:$port
    iptables -t nat -A POSTROUTING -p tcp -d $internal_ip --dport $port -j MASQUERADE
    
    # Add FORWARD rules
    iptables -A FORWARD -p tcp -d $internal_ip --dport $port -j ACCEPT
    iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
    
    echo -e "${GREEN}✓ Port forwarding added successfully!${NC}"
    echo -e "${GREEN}  External port $port → $internal_ip:$port${NC}"
}

# Function to remove forwarding rules silently (used internally)
remove_forwarding_silent() {
    local port=$1
    
    # Get all matching rules and remove them
    while iptables -t nat -L PREROUTING -n --line-numbers | grep -q "dpt:$port"; do
        line=$(iptables -t nat -L PREROUTING -n --line-numbers | grep "dpt:$port" | head -1 | awk '{print $1}')
        iptables -t nat -D PREROUTING $line 2>/dev/null
    done
    
    # Remove POSTROUTING rules
    while iptables -t nat -L POSTROUTING -n --line-numbers | grep -q "dpt:$port"; do
        line=$(iptables -t nat -L POSTROUTING -n --line-numbers | grep "dpt:$port" | head -1 | awk '{print $1}')
        iptables -t nat -D POSTROUTING $line 2>/dev/null
    done
    
    # Remove FORWARD rules
    while iptables -L FORWARD -n --line-numbers | grep -q "dpt:$port"; do
        line=$(iptables -L FORWARD -n --line-numbers | grep "dpt:$port" | head -1 | awk '{print $1}')
        iptables -D FORWARD $line 2>/dev/null
    done
}

# Function to remove port forwarding rules
remove_forwarding() {
    echo -e "${BLUE}=== Remove Port Forwarding ===${NC}"
    
    # First, show current rules
    list_forwarding
    
    read -p "Enter the port number to remove: " port
    
    # Validate port number
    if ! [[ $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
        echo -e "${RED}Error: Invalid port number${NC}"
        return 1
    fi
    
    # Check if rule exists
    if ! iptables -t nat -L PREROUTING -n | grep -q "dpt:$port"; then
        echo -e "${RED}Error: No forwarding rule found for port $port${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Removing forwarding rules for port $port...${NC}"
    
    remove_forwarding_silent $port
    
    echo -e "${GREEN}✓ Port forwarding rules removed successfully!${NC}"
}

# Function to list current port forwarding rules
list_forwarding() {
    echo -e "${BLUE}=== Current Port Forwarding Rules ===${NC}"
    echo ""
    echo -e "${YELLOW}Port Forwarding (DNAT) Rules:${NC}"
    echo "----------------------------------------"
    
    # Parse PREROUTING rules to show forwarding
    local found=false
    while IFS= read -r line; do
        if echo "$line" | grep -q "DNAT"; then
            port=$(echo "$line" | grep -oP 'dpt:\K[0-9]+')
            destination=$(echo "$line" | grep -oP 'to:\K[0-9.]+:[0-9]+')
            if [ ! -z "$port" ] && [ ! -z "$destination" ]; then
                echo -e "  ${GREEN}Port $port${NC} → ${GREEN}$destination${NC}"
                found=true
            fi
        fi
    done < <(iptables -t nat -L PREROUTING -n 2>/dev/null)
    
    if [ "$found" = false ]; then
        echo -e "  ${YELLOW}No port forwarding rules found${NC}"
    fi
    
    echo ""
}

# Function to show detailed iptables info
show_detailed() {
    echo -e "${BLUE}=== Detailed iptables Rules ===${NC}"
    echo ""
    echo -e "${YELLOW}NAT PREROUTING:${NC}"
    iptables -t nat -L PREROUTING -n -v --line-numbers
    echo ""
    echo -e "${YELLOW}NAT POSTROUTING:${NC}"
    iptables -t nat -L POSTROUTING -n -v --line-numbers
    echo ""
    echo -e "${YELLOW}FORWARD:${NC}"
    iptables -L FORWARD -n -v --line-numbers | head -20
}

# Main menu
main_menu() {
    while true; do
        echo ""
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        echo -e "${BLUE}     Port Forwarding Management Tool     ${NC}"
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        echo ""
        echo "1) Add port forwarding"
        echo "2) Remove port forwarding"
        echo "3) List current forwarding rules"
        echo "4) Show detailed iptables rules"
        echo "5) Exit"
        echo ""
        read -p "Select an option [1-5]: " choice
        
        case $choice in
            1)
                add_forwarding
                ;;
            2)
                remove_forwarding
                ;;
            3)
                list_forwarding
                ;;
            4)
                show_detailed
                ;;
            5)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Try: sudo $0"
    exit 1
fi

# Start the main menu
main_menu