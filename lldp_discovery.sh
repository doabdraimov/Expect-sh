#!/usr/bin/expect -f

set timeout 15
set user "admin"
set password "admin"
set log "/tmp/log.txt" 


set ip_addr(Oc.MSC_3.CR_01)	"172.28.200.1"
set ip_addr(Oc.MSC_3.CR_02)	"172.28.200.2"
set ip_addr(Oc.MSC_3.AC_01)	"172.28.200.3"
set ip_addr(Oc.MSC_3.AC_02)	"172.28.200.4"
set ip_addr(Oc.AmrTe.AC_01)	"172.28.200.5"
set ip_addr(Oc.AmrTe.AC_02)	"172.28.200.6"
set ip_addr(Oc.RemZv.AC_01)	"172.28.200.8"
set ip_addr(Oc.DByta.AC_01)	"172.28.200.9"
set ip_addr(Oc.Shelk.AC_01)	"172.28.200.10"
set ip_addr(Oc.GTS__.AC_01)	"172.28.200.12"
set ip_addr(Oc.PSouz.AC_01)	"172.28.200.13"
set ip_addr(Oc.HimCh.AC_01)	"172.28.200.14"
set ip_addr(Oc.Vysot.AC_01)	"172.28.200.15"
set ip_addr(Oc.JArk2.AC_01)	"172.28.200.16"
set ip_addr(Oc.OtAd2.AC_01)	"172.28.200.17"
set ip_addr(Oc.OtAdr.AC_01)	"172.28.200.18"
set ip_addr(Oc.Kurs2.AC_01)	"172.28.200.20"
set ip_addr(Oc.Kursh.AC_01)	"172.28.200.21"
set ip_addr(Oc.Kurs3.AC_01)	"172.28.200.22"
set ip_addr(Oc.Kshro.AC_01)	"172.28.200.23"
set ip_addr(Oc.Sherl.AC_01)	"172.28.200.24"
set ip_addr(Oc.Uzge5.AC_01)	"172.28.200.25"
set ip_addr(Oc.Upark.AC_01)	"172.28.200.26"
set ip_addr(Oc.Uzge2.AC_01)	"172.28.200.27"
set ip_addr(Oc.UVino.AC_01)	"172.28.200.28"
set ip_addr(Oc.ShBst.AC_01)	"172.28.200.29"
set ip_addr(Jc.Tasht.AC_01)	"172.28.200.30"
set ip_addr(Jc.Komsm.AC_01)	"172.28.200.31"
set ip_addr(Jc.Ofis_.AC_01)	"172.28.200.33"
set ip_addr(Oc.Cherm.AC_01)	"172.28.200.34"
set ip_addr(Oc.Zapad.AC_01)	"172.28.200.35"
set ip_addr(Jc.JaBSC.CR_01)	"172.28.200.40"
set ip_addr(Jc.JaBSC.CR_02)	"172.28.200.41"
set ip_addr(Jc.JaBSC.AC_01)	"172.28.200.42"
set ip_addr(Jc.JaBSC.AC_02)	"172.28.200.43"
set ip_addr(Jc.Lesho.AC_01)	"172.28.200.44"
set ip_addr(Jc.Spasv.AC_01)	"172.28.200.45"
set ip_addr(Jc.PVS__.AC_01)	"172.28.200.46"
set ip_addr(Jc.Pocht.AC_01)	"172.28.200.47"
set ip_addr(Jc.KocA2.AC_01)	"172.28.200.48"
set ip_addr(Jc.Mata_.AC_01)	"172.28.200.49"


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
				expect -re $ ; # чистим буфер 
				match_max 10000
				set expect_out(buffer) {}
				
				send "show system lldp neighbor \r               "
				set show_lldp_neighbor ""
				# Записываем в буфер вывод из команды show system lldp neighbor
				expect {
					{full_buffer} {
						puts "====== FULL BUFFER ======"
						# записываем данные с буфера в переменую show_lldp_neighbor
						set show_lldp_neighbor $expect_out(buffer)
						exp_continue
					}
					"#" {
						# записываем данные с буфера в переменую show_lldp_neighbor
						set show_lldp_neighbor $expect_out(buffer) 
					}
				}
				# выводим какие данные попали в переменую show_lldp_neighbor
				# puts $show_lldp_neighbor
				# ищу  в переменой show_lldp_neighbor совпадения с *NB*
				set devices [list]
				set current_device ""
				set lines [split $show_lldp_neighbor "\n"]
				foreach line $lines {
					set line [string trim $line]
					if {[llength $line] == 1} {
						set current_device $line     ;# 
						continue
					}
					set line "$current_device$line\n"
					if {[string match {* NB *} $line]} {
						append devices $line         ;# пишем в переменую devices все совпадения с {* NB *}
					}
				}	
				# получаем количество строк для цикла
				set string_count   [llength  [split $devices \n] ]
				# выводим количество строк для отладки
				# puts "string count is $string_count"
				
				#запускаю цикл по количеству строк. минус один цикл, потому что последняя строка пустая 
				for {set j 0} {$j < ($string_count - 1)} {incr j 1} {
					# выводим строку из переменной $devices по строчно(строку $j)
					set var_string [lindex [split $devices \n] $j]

					# показываем строку #j для отладки
					#puts "Curent string is:$var_string"
					
					# парсим вывод на переменные
					regexp {(\d+\/\d+\/\d+)} $var_string local_interface   ;#парсим вывод var_string для создания новой переменной local_interface
					# puts "Local interface is $local_interface"			 ;# выводим локальный интерфейс для отладки
					regexp {(\d+\/\d+\/\d+(?=,))} $var_string remote_interface
					# puts "Remote interface is $remote_interface"         ;# выводим удаленный интерфейс для отладки
					regexp {\w+\.\w+\.\w+\_\d+} $var_string remote_device_name
					# puts "Remote NE is $remote_device_name"            	 ;# выводим удаленный сетевой элемент для отладки

					expect ""
					send "configure port $local_interface description \"$remote_device_name $remote_interface MMM\" \r    "
					#puts "configure port $local_interface description \"$remote_device_name $remote_interface\" \r"
					
		
					# Тут может быть будет, когда нибудь проверка исполнеиния команд 
					#  send "\r"
					#  send "\r"
					#  send "show port description | match expression \"$local_interface \"\r"
					#  send "\r"
					# 
					#	expect {
					#		-glob "IPBB $remote_device_name $remote_interface" {
					#			exec echo "\"$remote_device_name\" configure port $local_interface description \"IPBB $remote_device_name $remote_interface\" \r" >> $log;
					#			puts ""
					#			puts "OK"
					#		}
					#		-regexp "^\d+\/\d+\/\d+          (?!IPBB)" {
					#			exec echo "ERR -- \"$remote_device_name\" configure port $local_interface description \"IPBB $remote_device_name $remote_interface\" \r" >> $log;
					#			puts ""
					#			puts "ERR"
					#		}
					#	}
					
				}
				#выходим из текущей сесси
				send "admin save\r"
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

exit 0
