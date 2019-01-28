#!/usr/bin/expect -f

############### „исковери сетевых элементов NOKIA в сети 

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
						expect -re $ ; # чистим буфер 
						match_max 10000
						set expect_out(buffer) {}
						
						send "  \r"
						set var_buffer ""
						# Записываем в буфер вывод из команды send "  \r"
						expect {
							{full_buffer} {
								puts "====== FULL BUFFER ======"
								# записываем данные с буфера в переменую var_buffer
								set var_buffer $expect_out(buffer)
								exp_continue
							}
							"#" {
								# записываем данные с буфера в переменую var_buffer
								set var_buffer $expect_out(buffer) 
							}
						}
						# вытаскиваю 2 строчку из переменной var_buffer и парсим регуляркой
						set var_string [lindex [split $var_buffer \n] 1]
						regexp {\w+\.\w+\.\w+\_\d+} $var_string hostname
			
						puts "$hostname	$net$i"
						exec echo "set ip_addr($hostname)	\"$net$i\""  >> $log;
						#выходим из текущей сесси
						send "logout \r"
						#ловим "closed" после выхода из сесси чтобы коректно закончить текущий цикл
						expect {
							"closed" { break;}
						}
					}
					break; #выходим из цикла while
				}
			}	
		}		
	}
}

exit 0
