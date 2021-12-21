#!/bin/sh

VPC_ID=$(aws ec2 describe-vpcs --filter "Name=tag-key,Values=\"hwcharlton:site-manager-environment\"" --query "Vpcs[].VpcId" --output text)
SUBNET_ID=$(aws ec2 describe-subnets --filter "Name=vpc-id,Values=$VPC_ID" --query "Subnets[].SubnetId" --output text)
SECURITY_GROUPS=$(aws ec2 describe-security-groups --filter "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?!(GroupName=='default')].GroupId" --output text)
CIDR_BLOCKS="$(aws ec2 describe-route-tables --filter "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[*].Routes[?starts_with(GatewayId, \`igw\`)][][DestinationCidrBlock][]" --output text)"
IPV6_CIDR_BLOCKS="$(aws ec2 describe-route-tables --filter "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[*].Routes[?starts_with(GatewayId, \`igw\`)][][DestinationIpv6CidrBlock][]" --output text)"
ROUTE_TABLE_ID="$(aws ec2 describe-route-tables --filter "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[?! not_null(Associations)].RouteTableId" --output text)"
ROUTE_TABLE_ASSOCIATIONS="$(aws ec2 describe-route-tables --filter "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[].Associations[?! Main][].RouteTableAssociationId" --output text)"
INTERNET_GATEWAY_ID="$(aws ec2 describe-internet-gateways --filter "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[].InternetGatewayId" --output text)"

echo "INTERNET_GATEWAY_ID: $INTERNET_GATEWAY_ID"
echo "ROUTE_TABLE_ASSOCIATIONS: $ROUTE_TABLE_ASSOCIATIONS"
echo "ROUTE_TABLE_ID: $ROUTE_TABLE_ID"
echo "IPV6_CIDR_BLOCKS: $IPV6_CIDR_BLOCKS"
echo "CIDR_BLOCKS: $CIDR_BLOCKS"
echo "SECURITY_GROUPS: $SECURITY_GROUPS"
echo "SUBNET_ID: $SUBNET_ID"
echo "VPC_ID: $VPC_ID"

if [ -n "$ROUTE_TABLE_ASSOCIATIONS" ]; then
  echo "disassociating route tables"
  aws ec2 disassociate-route-table --association-id "$ROUTE_TABLE_ASSOCIATIONS"
fi

if [ -n "$ROUTE_TABLE_ID" ]; then
  echo "deleting route table"
  aws ec2 delete-route-table --route-table-id "$ROUTE_TABLE_ID"
fi

if [ -n "$INTERNET_GATEWAY_ID" ]; then
  echo "detaching and deleting internet gateway"
  aws ec2 detach-internet-gateway --vpc-id "$VPC_ID" --internet-gateway-id "$INTERNET_GATEWAY_ID"
  aws ec2 delete-internet-gateway --internet-gateway-id "$INTERNET_GATEWAY_ID"
fi

if [ -n "$IPV6_CIDR_BLOCKS" ]; then
  echo "deleting ipv6 cidr routes"
  aws ec2 delete-route --route-table-id "$ROUTE_TABLE_ID" --destination-ipv6-cidr-block "$IPV6_CIDR_BLOCKS"
fi

if [ -n "$CIDR_BLOCKS" ]; then
  echo "deleting cidr routes"
  aws ec2 delete-route --route-table-id "$ROUTE_TABLE_ID" --destination-cidr-block "$CIDR_BLOCKS"
fi

if [ -n "$SUBNET_ID" ]; then
  echo "deleting subnet"
  aws ec2 delete-subnet --subnet-id "$SUBNET_ID"
fi

if [ -n "$SECURITY_GROUPS" ]; then
  echo "deleting security groups"
  echo "$SECURITY_GROUPS" | xargs -n1 aws ec2 delete-security-group --group-id
fi

if [ -n "$VPC_ID" ]; then
  echo "deleting vpc"
  aws ec2 delete-vpc --vpc-id "$VPC_ID"
fi
