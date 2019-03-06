#!/usr/bin/expect -f

set timeout 15
set user "admin"
set password "admin"
set log "/tmp/log.txt" 


set ip_addr(Oc.MSC_3.CR_01)	"00:2e:c7:3d:cb:fe"
set ip_addr(Oc.MSC_3.CR_02)	"04:27:58:92:18:1e"
set ip_addr(Oc.MSC_3.AC_01)	"20:f1:7c:52:5e:70"
set ip_addr(Oc.MSC_3.AC_02)	"24:16:6d:7c:2a:f1"
set ip_addr(Oc.AmrTe.AC_01)	"24:16:6d:7c:2f:f1"
set ip_addr(Oc.AmrTe.AC_02)	"34:00:a3:3d:c6:b4"
set ip_addr(Oc.RemZv.AC_01)	"34:00:a3:3e:58:8a"
set ip_addr(Oc.DByta.AC_01)	"3c:15:fb:58:41:dd"
set ip_addr(Oc.Shelk.AC_01)	"48:8e:ef:ac:3c:2c"
set ip_addr(Oc.GTS__.AC_01)	"48:8e:ef:ac:3c:a4"
set ip_addr(Oc.PSouz.AC_01)	"4c:f9:5d:7c:ee:33"
set ip_addr(Oc.HimCh.AC_01)	"60:08:10:42:32:f5"
set ip_addr(Oc.Vysot.AC_01)	"60:08:10:43:39:89"
set ip_addr(Oc.JArk2.AC_01)	"60:08:10:43:3a:09"
set ip_addr(Oc.OtAd2.AC_01)	"60:08:10:43:3a:cd"
set ip_addr(Oc.OtAdr.AC_01)	"60:08:10:47:ca:4b"
set ip_addr(Oc.Kurs2.AC_01)	"60:2e:20:8b:0a:6a"
set ip_addr(Oc.Kursh.AC_01)	"60:2e:20:8b:0a:a6"
set ip_addr(Oc.Kurs3.AC_01)	"60:2e:20:8b:0a:ca"
set ip_addr(Oc.Kshro.AC_01)	"60:2e:20:8b:0b:9e"
set ip_addr(Oc.Sherl.AC_01)	"74:9d:8f:88:50:a0"
set ip_addr(Oc.Uzge5.AC_01)	"74:9d:8f:88:55:4c"
set ip_addr(Oc.Upark.AC_01)	"7c:c3:85:5f:3b:0f"
set ip_addr(Oc.Uzge2.AC_01)	"7c:c3:85:5f:3b:43"
set ip_addr(Oc.UVino.AC_01)	"80:d4:a5:93:77:c5"
set ip_addr(Oc.ShBst.AC_01)	"80:d4:a5:93:78:6d"
set ip_addr(Jc.Tasht.AC_01)	"80:d4:a5:93:78:e5"
set ip_addr(Jc.Komsm.AC_01)	"80:d4:a5:93:78:f1"
set ip_addr(Jc.Ofis_.AC_01)	"90:03:25:54:61:3c"
set ip_addr(Oc.Cherm.AC_01)	"9c:7d:a3:c3:c1:84"
set ip_addr(Oc.Zapad.AC_01)	"ac:75:1d:65:82:9e"
set ip_addr(Jc.JaBSC.CR_01)	"c0:bf:c0:d1:df:30"
set ip_addr(Jc.JaBSC.CR_02)	"c4:b8:b4:55:62:8a"
set ip_addr(Jc.JaBSC.AC_01)	"c4:b8:b4:63:44:db"
set ip_addr(Jc.JaBSC.AC_02)	"c4:b8:b4:63:45:53"
set ip_addr(Jc.Lesho.AC_01)	"c4:b8:b4:63:45:df"
set ip_addr(Jc.Spasv.AC_01)	"f8:75:88:c2:3e:82"


spawn ssh $user@172.28.200.1;

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

					set  iplist  [array names ip_addr]
					for {set i 0} {$i < [llength $iplist]}  { incr i } {
						set  name  [lindex $iplist $i] ;# get  name      
						set timestamp [clock seconds]
						expect -re $ ; # чистим буфер 
						match_max 10000
						set expect_out(buffer) {}
						
						send "show router 150000001 arp | match $ip_addr($name) \r               "
						set show_arp ""
						# «аписываем в буфер вывод из команды show system lldp neighbor
						expect {
							{full_buffer} {
								puts "====== FULL BUFFER ======"
								# записываем данные с буфера в переменую show_arp
								set show_arp $expect_out(buffer)
								exp_continue
							}
							"#" {
								# записываем данные с буфера в переменую show_arp
								set show_arp $expect_out(buffer) 
							}
						}
									
						# выводим какие данные попали в переменую show_arp
						#puts $show_arp
									
						# пишке в переменую var_string что папало со 2ой строки от show_arp и парсим ип адрес
						set var_string [lindex [split $show_arp \n] 1]
						regexp {\d+\.\d+\.\d+\.\d+} $show_arp ip_addres
							
						# тут все просто пишем в файлик ип адреса	
						exec echo "$ip_addres"  >> $log;
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

exit 0
