#!/usr/bin/env python3.6
import pexpect # Expect в питоне
import getpass # Чтобы пароль не святился как в линуксе или циске
import re # Регулярные выражения

user_name=input('Login:')
user_password=getpass.getpass()
# Список устройств
device_ip=['172.28.139.7','172.28.139.10','172.28.139.14']

for IP in device_ip:
	#print('Connection to {}'.format(IP))
	ssh = pexpect.spawn('ssh {}@{}'.format(user_name,IP))
	kkk=ssh.expect (['RSA key fingerprint is', 'password'])
	
	# Проверка если новый хост и нет RSA ключей для SSH, то сохроняем
	if kkk==0:
		print('Save new RSA key fingerprint by host {}'.format(IP))
		ssh.sendline('yes')
	
	#Пытаюсь залогиниться
	ssh.sendline(user_password)
	jjj=ssh.expect (['Connection closed by', 'Permission denied, please try again.','#'])
	
	#Если не получается пройти аутентификацию, то прыгаем на следующую итерацию(логин или пароль не верны)
	if jjj==0:
		print('Connection closed by {}. Can\'t login. Please check login & password.'.format(IP))
		continue
	elif jjj==1:
		print('Permission denied to {}. Can\'t login. Please check login & password.'.format(IP))
		continue
	
	#print('Logined on host{}'.format(IP))

	# Получаем System name
	ssh.sendline('show system information | match "System Name"')
	ssh.expect('#')
	System_Name=list(str(ssh.before.decode('utf-8')).split())[-2] 
	print('System name of {} is:'.format(IP), System_Name)

	#send command lldp neighbor 
	ssh.sendline('show system lldp neighbor | match expression "[0-9]+/[0-9]+/[0-9]+"')
	ssh.expect('#')
	#Можно распечатать вывод комманды ('show system lldp neighbor | match expression "[0-9]+/[0-9]+/[0-9]+"') для дебага
	#print(ssh.before.decode('utf-8'))
	#write to variable output from command lldp neighbor
	Lldp_Neighbor=ssh.before.decode('utf-8')
	
	#Удаляем через регулятрные выражения (, и *) в ввыводе комманды "show system lldp neighbor" чтобы не было 1/1/2, 10/100/*
	# и сразу делим по строчно
	# show system lldp neighbor | match expression "[0-9]+/[0-9]+/[0-9]+"
	# 1/1/1     NB     84:26:2B:62:B1:71   10     1/1/2, 10/100/* Bc.UzelA.CR_01
	# 1/1/24    NB     8C:90:D3:BE:A2:F2   14     1/1/24, 10/100* Bc.UzelA.AC_01
	Neigbor=(re.sub(r',|\*|\/\*', '', Lldp_Neighbor)).split('\n')
	
	#Запускаем цикл по срезу списка(тоесть, удаляем первые и последние строки) Neigbor [1:-1] 
	for Interface in Neigbor[1:-1]:
		#Делим строчку по пробелу и превращяем в список
		#далее по номеру индекса присваеваем ее к переменным Local_interface, Remote_interface, Remote_device
		x=Interface.split()
		Local_interface=x[0]
		Remote_interface=x[4]
		Remote_device=x[6]
		print('/configure port', Local_interface, "description", Remote_device, Remote_interface, "MMM")
		#ssh.sendline('/configure port {} description "{} {} MMM"'.format(Local_interface,Remote_device,Remote_interface))
		#ssh.expect('#')
		
		
	#Закрываем ssh сессию
	ssh.close()
