#!/usr/bin/expect -f

set timeout 2
set user "admin"
set password "admin"
set log "/tmp/log.txt" 


set ip_addr(15003) "172.28.200.3"
set ip_addr(15005) "172.28.200.5"
set ip_addr(15006) "172.28.200.6"
set ip_addr(15009) "172.28.200.9"
set ip_addr(15010) "172.28.200.10"
set ip_addr(15012) "172.28.200.12"
set ip_addr(15013) "172.28.200.13"
set ip_addr(15014) "172.28.200.14"
set ip_addr(15015) "172.28.200.15"
set ip_addr(15017) "172.28.200.17"
set ip_addr(15020) "172.28.200.20"
set ip_addr(15021) "172.28.200.21"
set ip_addr(15023) "172.28.200.23"
set ip_addr(15024) "172.28.200.24"
set ip_addr(15025) "172.28.200.25"
set ip_addr(15027) "172.28.200.27"
set ip_addr(15028) "172.28.200.28"
set ip_addr(15029) "172.28.200.29"

# номер сервиса и sdp которые проверяем 
set sdp "15016"
set service_id "150001341"

# химчистка логов
exec echo ""  > $log;


set  iplist  [array names ip_addr]
for {set i 0} {$i < [llength $iplist]}  { incr i } {
    set  name  [lindex $iplist $i] ;# get  name      
	set timestamp [clock seconds]

  	spawn ssh $user@$ip_addr($name);
	
	while 1  {
			expect {
				"denied" 					{puts  "[clock format $timestamp -format %Y:%m:%d-%H:%M:%S] : Can't login $name"; break;} 
				"failed"      				{puts  "[clock format $timestamp -format %Y:%m:%d-%H:%M:%S] : Check ssh_hosts file $name"; break;}
				"timeout"      	 			{puts  "[clock format $timestamp -format %Y:%m:%d-%H:%M:%S] : Timeout problem $name"; break;}
				"Connection refused" 		{puts  "[clock format $timestamp -format %Y:%m:%d-%H:%M:%S] : Connection refused by $name"; break;}
				"No route to host" 			{puts  "[clock format $timestamp -format %Y:%m:%d-%H:%M:%S] : No route to host $name"; break;}
				"Connection closed" 		{puts  "[clock format $timestamp -format %Y:%m:%d-%H:%M:%S] : Connection closed by $name"; break;}
				"Connection reset by peer" 	{puts  "[clock format $timestamp -format %Y:%m:%d-%H:%M:%S] : Connection reset by peer $name"; break;}
				"refused" 					{puts  "[clock format $timestamp -format %Y:%m:%d-%H:%M:%S] : Connection refused $name"; break;}
				"no)?"						{send "yes\r"}
				"assword:*" 				{send "$password\r"}
				"*>"						{send "enable\r"}
				"*#"	{    
						set timestamp [clock seconds]
						send "show service sdp-using | match $sdp:$service_id \r               \r"
				
						expect {
							"Down" {
										send "configure service vpls $service_id \r"
										send "mesh-sdp $sdp:$service_id  shutdown \r"
										send "no mesh-sdp $sdp:$service_id \r"
										send "/admin save \r "
									}
						}

						send "logout \r"
						#ловим "closed" после выхода из сесси чтобы коректно закончить текущий цикл
						expect {
							"closed" { break;}
						}
										
										
						break; #выходим из цикла while
				}
		}
	}
}
exit 0
