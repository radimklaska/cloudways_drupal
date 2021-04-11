# CLOUDWAYS-PROJECT-NAME CloudWays Drupal 9

# Setup

## Cloudways setup

* Register an account on Cloudways https://vrlps.co/8KpI0vD/cp (referral, thank you)
* Create a new server
  * https://platform.cloudways.com/server
  * `APPLICATION & SERVER DETAIL`: `Custom App` (even for Drupal)
  * `Name your management app`: Pick a good "machine name", this will become `CLOUDWAYS-PROJECT-NAME`.
  * `Name yout server`: This is up to you.
  * `DigitalOcean` / `2GB` / `Frankfurt` is good cheap start for small site targeting EU users.
  * // Wait for the server to build.
  * `Master Credentials`: Add your main SSH key.
  * `Settings & Packages` - Set up your environment.
    * Note `MAX INPUT VARIABLES` - this might be limiting for permissions pages in Drupal.
    * Set correct time zone.
    * Set MySQL `ENCODING` to `UTF-8`.
    * Set desired PHP version.
    * Set correct time zone.
    * Set correct time zone.
  * `Backups`: Configure your backup rotation. I would recommend enabling `Local Backups` if your apps are not big.
  * `SMTP`: I recommend `Elastic Email` Add-on: https://support.cloudways.com/how-to-activate-elasticemail-addon/ (Basic subscription includes 1000 Emails for $0.10 / Month)
* Set up the application.
  * https://platform.cloudways.com/apps
  * Add new app or edit the first one that was created with your new server. 
  * `APPLICATION CREDENTIALS`
    * Note the `Public IP`. Now is a good time to point a domain to the IP. That's outside the scope of this how-to.
    * Add new Username and password. This will be used for deployments.
        * Username: `CLOUDWAYS-PROJECT-NAME`
        * Password: Strong password.
  * `Domain Management`: Add the primary domain and secondary domains. (`www.*`)
  * `SSL Certificate`: SSL is handled by Let's Encrypt and verified trough DNS. You can enable it now.
  * `Deployment via Git`: *Don't use this feature.* It's missing features required for deploying Drupal. (at the time of writing)
  * `Application Settings`
    * `FOLDER`: change this to `CLOUDWAYS-PROJECT-NAME`
    * `WEBROOT`: change this to `public_html/docroot` (fill in only `docroot`)
    * `SSH ACCESS `: Enable

## Access

### Cloudways

* Check you can SSH into the APP's account: `ssh CLOUDWAYS-PROJECT-NAME@CLOUDWAYS-PROJECT-DOMAIN` using the per-app password.
  * This should just work. If it does not, double-check the Cloudways setup again.
* Create new SSH key pair *without a password* in some temporary folder.
```
✔ rk:~> mkdir -p /tmp/cloudways-ssh
✔ rk:~> cd /tmp/cloudways-ssh/
✔ rk:/tmp/cloudways-ssh> ssh-keygen -t rsa -b 4096 -C "CLOUDWAYS-PROJECT-NAME"
Generating public/private rsa key pair.
Enter file in which to save the key (/home/radimklaska/.ssh/id_rsa): /tmp/cloudways-ssh/id_rsa
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /tmp/cloudways-ssh/id_rsa
Your public key has been saved in /tmp/cloudways-ssh/id_rsa.pub
The key fingerprint is:
SHA256:w*******H+E**************************O/u**o CLOUDWAYS-PROJECT-NAME
The key's randomart image is:
+---[RSA 4096]----+
|         .. +=B.o|
|     +  ..oo.* B |
|    . + .=.o..B  |
|       +o o.o. . |
|     . R.K. Iz . |
|        = o Da ..|
|       o .Best.o=|
|          .E= *.+|
|          .+LoL. |
+----[SHA256]-----+
✔ rk:/tmp/cloudways-ssh> ll
total 24
drwxrwxr-x  2 radimklaska radimklaska  4096 dub 11 18:56 ./
drwxrwxrwt 52 root        root        12288 dub 11 18:54 ../
-rw-------  1 radimklaska radimklaska  3381 dub 11 18:56 id_rsa
-rw-r--r--  1 radimklaska radimklaska   739 dub 11 18:56 id_rsa.pub
```
* Save those in your password manager.
* Go to Cloudways, manage your App. Under `Access Details` there is a `SSH KEYS` button next to the `APPLICATION CREDENTIALS` that was adedd.
  * Add the public key (content `id_rsa.pub`) there.

### GitHub Secrets

On https://github.com/radimklaska/CLOUDWAYS-PROJECT-NAME/settings/secrets/actions add following repository secrets:

* `DeployCloudwaysPrivateKey`: Content of `id_rsa`
* `DeployCloudwaysUsername` == CLOUDWAYS-PROJECT-NAME
* `DeployCloudwaysHostname` == CLOUDWAYS-PROJECT-DOMAIN
* `DeployCloudwaysPath`:
  * something like `/home/123456.cloudwaysapps.com/abcdef/public_html`
  * SSH into `ssh CLOUDWAYS-PROJECT-NAME@CLOUDWAYS-PROJECT-DOMAIN` and run `pwd` to get the path:
    ```
    abcdef@123456 ~/public_html $ pwd
    /home/123456.cloudwaysapps.com/abcdef/public_html
    abcdef@123456 ~/public_html $
    ```

## Code

* https://github.com/radimklaska/cloudways_drupal9 and click the `Use this template` button.
  * Name your new repo: `CLOUDWAYS-PROJECT-NAME`
  * Clone it locally and get ready to edit.  

### Search and replace

* `CLOUDWAYS-PROJECT-DOMAIN`: this is bare domain, like `actual-domain.com`
* `CLOUDWAYS-PROJECT-NAME`: this should be very simple name, avoid spaecial characters, like `actual-name`

```
find ./ -type f \( -iname \*.yml -o -iname \*.sh -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' -e 's/CLOUDWAYS-PROJECT-DOMAIN/actual-domain.com/g' &&
find ./ -type f \( -iname \*.yml -o -iname \*.sh -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' -e 's/CLOUDWAYS-PROJECT-NAME/actual-name/g'
```

## Notes:
* Set up your cron in the App settings under `Cron Job Management`.
