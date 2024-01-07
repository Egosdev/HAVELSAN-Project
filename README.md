# HAVELSAN-Liman-Installer
> [!NOTE]
> This script is Liman installation manager wizard shell.

## What is Liman?
It is an Open Source Central Management System. 

Liman Center Management System helps you effectively manage your organization's Information Technology Services. You can centrally manage all the components of your Information Technologies (IT) processes remotely, with stable, secure and extensible methods.

[Liman Center Management System Guide](https://docs.liman.dev/)

## What does shell script do?
Using the script, you can easily install the Liman central management system and its dependencies without drowning in codes.

**Provides,**
- [x] Install
- [X] Uninstall
- [x] Display services status
- [x] Reset admin or user's password via mail

**Installs,**
- [x] PHP,
- [x] NodeJS,
- [x] PostgreSQL,
- [x] Liman via github.

## Script Usage

- Go to the directory where the shell script you downloaded is located. `cd <file dir>`
- Authorize the file to run it. `chmod +x liman.sh`
- Start the installation. `./liman.sh install`
- After the installation is completed, the status of the services should be as follows: **RUNNING**

> [!IMPORTANT]
> During the installation, it will ask to download a file of **~200 MB**, you must accept it. **(y)**

The downloaded file does not stay on your system, it is installed as soon as it is downloaded and disappears.

> [!TIP]
> You can check the status of the installation step by step from the log file with date and time.
```bash
cat /liman/installer.log
```

> [!TIP]
> You can use all the commands in Turkish.
```bash
./liman.sh kur
```

## Help Turkish

### Kullanım 
`./liman.sh <komut>`
```bash
Komutlar:
 ./liman.sh kur               -> Limanı kurar. (Son sürüm)
 ./liman.sh kaldır            -> Limanı kaldırır.
 ./liman.sh sağlık            -> Liman servislerinin durumlarını gösterir.
 ./liman.sh adminyenile       -> Liman yönetici parolasını sıfırlar.
 ./liman.sh reset <e-posta>   -> Yazılan e-posta adreslerine göre parolayı sıfırlar.
 ./liman.sh yardım            -> Komutların nasıl kullanıldığını görüntüler."
```

## Known Issues

> [!CAUTION]
> After installing the Liman, when you try to uninstall and reinstall it, Nginx gives a service error.

