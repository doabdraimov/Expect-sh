#!/usr/bin/expect -f

############### ��������� ������� ��������� NOKIA � ���� 

set timeout 15
set user "admin"
set password "admin"
set log "/tmp/log.txt" 
set net "172.28.200."

for {set i 1} {$i < 255}  { incr i } {
   
spawn ping -c 2 -i 1 -W 1 $net$i

expect  {
		" 100%" {puts "100% loss jump to next ->"}
		" 50%"  {exec echo "50%loss	$net$i"  >> $log;}
        " 0%" {
			spawn ssh $user@$net$i
			while 1  {
				expect {
					"denied" 					{puts  " Can't login $name"; break;} 
					"failed"      				{puts  " Check ssh_hosts file $name"; break;}
					"timeout"      	 			{puts  " Timeout problem $name"; break;}
					"Connection refused" 		{puts  " Connection refused by $name"; break;}
					"connect to host" 			{puts  " Connection refused by $name"; break;}
					"No route to host" 			{puts  " No route to host $name"; break;}
					"Connection reset by peer" 	{puts  " Connection reset by peer $name"; break;}
					"refused" 					{puts  " Connection refused $name"; break;}
					"no)?"						{send "yes\r"}
					"assword:*" 				{send "$password\r"}
					"*>"						{send "enable\r"}
					"*#"	{ 
						expect -re $ ; # ������ ����� 
						match_max 10000
						set expect_out(buffer) {}
						
						send "  \r"
						set var_buffer ""
						# ���������� � ����� ����� �� ������� send "  \r"
						expect {
							{full_buffer} {
								puts "====== FULL BUFFER ======"
								# ���������� ������ � ������ � ��������� var_buffer
								set var_buffer $expect_out(buffer)
								exp_continue
							}
							"#" {
								# ���������� ������ � ������ � ��������� var_buffer
								set var_buffer $expect_out(buffer) 
							}
						}
						# ���������� 2 ������� �� ���������� var_buffer � ������ ����������
						set var_string [lindex [split $var_buffer \n] 1]
						regexp {\w+\.\w+\.\w+\_\d+} $var_string hostname
			
						puts "$hostname	$net$i"
						exec echo "set ip_addr($hostname)	\"$net$i\""  >> $log;
						#������� �� ������� �����
						send "logout \r"
						#����� "closed" ����� ������ �� ����� ����� �������� ��������� ������� ����
						expect {
							"closed" { break;}
						}
					}
					break; #������� �� ����� while
				}
			}	
		}		
	}
}

exit 0
