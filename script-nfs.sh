#############################################
#											#
# 			S E R V I D O R		N F S       #
#											#
#############################################

#1 instalación del sistema operativo
	Red Hat Enterprise Linux release 8.2 (Ootpa)

#2 Logearse a nivel de subscription manager.
	subscription-manager register --username castanedarakruger --password Ronald1992. --auto-attach
#3 instalar paquetes 
	sudo yum install nfs-utils -y

#4 Activar los servicios a nivel de systemd.
	sudo systemctl enable --now rpcbind
	sudo systemctl enable --now nfs-server

#5 revisamos estado de servicio sudo systemctl status nfs-server.service
	sudo systemctl status rpcbind
	sudo systemctl status nfs-server

#6 configuramos estas reglas en el firewall
	firewall-cmd --permanent --add-service=mountd
	firewall-cmd --permanent --add-service=rpc-bind
	firewall-cmd --permanent --add-service=nfs
	firewall-cmd --reload

#7 Revisar disco adicional para el almacenamiento, si no existe solicitarlo
	fdisk -l

#8 Crear una particion primaria o logica.

	fdisk /dev/sdb
	#Crear una nueva particion (opcion n) 
	#Last sector, +sectors or +size{K,M,G,T,P} (2048-209715199, default 209715199): +524M
	#Device     Boot Start     End Sectors  Size Id Type
	#/dev/sdb1        2048 1034239 1032192  504M 83 Linux
		
    partprobe -s

    mkfs.ext3 -L my-ext /dev/sdb1


#9 Dar formato a la particion.

	#Opcion 1:
	 mkfs.ext3 -L my-ext /dev/sdb1
	#Opcion 2:
	 mkfs.ext3 /dev/sdb1
	#Opcion 3:
	 mkfs -t ext3 /dev/nombre del disco


#10 crear el file system

    mkdir -p /mnt/app
    chown nobody /mnt/app

    blkid | grep my-ext
    echo "LABEL=my-app  /mnt/app ext3 defaults 0 0 " >> /etc/fstab

    mount -a
    df -hT

#11 Configurar NFS SERVER
	echo "/mnt/app *(rw)" >> /etc/exports
        echo "/nfs-dir/elk/snapshots *(rw,sync,no_root_squash)" >> /etc/exports
	exportfs -vr

#12 Reiniciar NFS.
	systemctl restart nfs-server

#############################################
#											#
#		C L I E N T E 		N F S	        #
#											#
#############################################


#1 instalación del sistema operativo
	Red Hat Enterprise Linux Server release 7.6 (Maipo)

#2 Logearse a nivel de subscription manager.
	subscription-manager register --username castanedarakruger --password Ronald1992. --auto-attach

#3 instalar paquetes 
	sudo yum install nfs-utils -y

#4 Creamos la carpeta de montaje
	mkdir /carpeta-nfs

#5 Verificar los directorios expuestos en el servidor NFS.
	showmount -e 192.168.111.128

#6 Montamos de manera temporal para probar el NFS.
	mount -t nfs -o vers=3 ip_address_server:/srv/nfs /carpeta-nfs
	mount -t nfs -o vers=3 192.168.111.128:/mnt/app /mnt/app
	umount /mnt/app
	
#7 Agregar la configuracion del montaje en el archivo fstab.
   #Utilizar cualquiera de estas opciones para editar el fichero fstab (Version NFS).
   
	#Version 4
	echo “192.168.111.128:/mnt/app /mnt/app nfs vers=4,_netdev  0 0” >> /etc/fstab
    #Version 3
	echo “192.168.111.128:/mnt/app /mnt/app nfs vers=3,_netdev  0 0” >> /etc/fstab
	#Version defecto (4)
    echo “192.168.111.128:/mnt/app /mnt/app nfs _netdev  0 0” > /etc/fstab
  #Actualizar los montajes.
	mount -a
  #Verificar el FS
	df -hT
	
	
