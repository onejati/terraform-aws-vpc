#------------------------------------------#
# VPC Configuration
#------------------------------------------#
resource "aws_vpc" "main" {
    cidr_block           = "10.22.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags {
        Name = "${var.tag_name}-vpc"
    }
}
#--------------Public-Subnet----------------#
resource "aws_subnet" "WWW_a" {
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = "10.22.1.0/24"
    availability_zone       = "${var.region}a"
    map_public_ip_on_launch = true
    tags {
      Name = "WWW-${var.tag_name}-a"
    }
}

resource "aws_subnet" "WWW_b" {
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = "10.22.2.0/24"
    availability_zone       = "${var.region}b"
    map_public_ip_on_launch = true
    tags {
      Name = "WWW-${var.tag_name}-b"
    }
}

resource "aws_subnet" "WWW_c" {
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = "10.22.3.0/24"
    availability_zone       = "${var.region}c"
    map_public_ip_on_launch = true
    tags {
      Name = "WWW-${var.tag_name}-c"
    }
}
#------------------Private-Subnet----------------#

resource "aws_subnet" "APP_a" {
    vpc_id                  = "${aws_vpc.main.id}"
    cidr_block              = "10.22.4.0/24"
    availability_zone       = "${var.region}a"                         
                                                    
    tags {                                          
        Name = "APP-${var.tag_name}-a"
    }                                               
}
resource "aws_subnet" "APP_b" {
    vpc_id             = "${aws_vpc.main.id}"
    cidr_block         = "10.22.5.0/24"
    availability_zone  = "${var.region}b"                         
                                                    
    tags {                                          
        Name = "APP-${var.tag_name}-b"
    }                                               
}
resource "aws_subnet" "APP_c" {
    vpc_id             = "${aws_vpc.main.id}"
    cidr_block         = "10.22.6.0/24"
    availability_zone  = "${var.region}c"                         
                                                    
    tags {                                          
        Name = "APP-${var.tag_name}-c"
    }                                               
}
resource "aws_subnet" "DB_a" {
    vpc_id             = "${aws_vpc.main.id}"
    cidr_block         = "10.22.7.0/24"
    availability_zone  = "${var.region}b"                         
                                                    
    tags {                                          
        Name = "DB-${var.tag_name}-a"
    }                                               
}
resource "aws_subnet" "DB_b" {
    vpc_id             = "${aws_vpc.main.id}"
    cidr_block         = "10.22.8.0/24"
    availability_zone  = "${var.region}b"                         
                                                    
    tags {                                          
        Name = "DB-${var.tag_name}-b"
    }                                               
}
#-------------------IGW------------------------#
resource "aws_internet_gateway" "main" {          
    vpc_id          = "${aws_vpc.main.id}"             
    depends_on      = ["aws_vpc.main"]                 
    tags {                                              
      Name          = "${var.tag_name}-igw"                      
    }                                                   
}                                                       
#----------------NAT-gateway-------------------#
resource "aws_eip" "main" {                          
  vpc = true                                        
}                                                                                                   
resource "aws_nat_gateway" "main" {                
    allocation_id   = "${aws_eip.main.id}"             
    subnet_id       = "${aws_subnet.WWW_a.id}" 
    tags {
        Name        = "{var.tag_name}-nat"
    }	
}

#---------------------VGW----------------------#
resource "aws_vpn_gateway" "main" {
    vpc_id         = "${aws_vpc.main.id}"
	depends_on     = ["aws_vpc.main"] 

    tags {
        Name       = "{var.tag_name}-vgw"
    }
}
#------------------Public-Route----------------#                                                 
resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block   = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main.id}"
    }
    route {
        cidr_block = "10.2.0.0/0"
        gateway_id = "${aws_vpn_gateway.main.id}"
    }
    tags {
        Name = "public_Access"
    }
}
#------------------Private-Route----------------#
resource "aws_route_table" "private" {              
    vpc_id = "${aws_vpc.main.id}"                
    route {                                      
        cidr_block = "0.0.0.0/0"                 
        nat_gateway_id = "${aws_nat_gateway.main.id}"  
    }                                            
    route {
        cidr_block = "10.2.0.0/0"
        gateway_id = "${aws_vpn_gateway.main.id}"
    }                                                 
    tags {                                       
        Name = "Private_Access"                                     
    }                                            
} 
#-----------Private-Route-association------------#
resource "aws_route_table_association" "private-1" {  
  subnet_id = "${aws_subnet.APP_a.id}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private-2" {  
  subnet_id = "${aws_subnet.APP_b.id}" 
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private-3" {  
  subnet_id = "${aws_subnet.DB_a.id}" 
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private-4" {  
  subnet_id = "${aws_subnet.DB_b.id}" 
  route_table_id = "${aws_route_table.private.id}"
}       
#-----------Private-Route-association----------------#
resource "aws_route_table_association" "public-1" {  
  subnet_id = "${aws_subnet.WWW_a.id}"   
  route_table_id = "${aws_route_table.public.id}"  
}
resource "aws_route_table_association" "public-2" {  
  subnet_id = "${aws_subnet.WWW_b.id}"    
  route_table_id = "${aws_route_table.public.id}"  
}  
