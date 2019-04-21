# MediaWiki Docker Image (with Parsoid & VisualEditor)

Based on MediaWiki release [1.32.1](https://www.mediawiki.org/wiki/Release_notes/1.32.1).

Requires Docker version 1.11.2 and up

The image is built and uploaded to [Docker Hub](https://hub.docker.com/r/revianlabs/mediawiki-ve-bundle).

Installed extensions (23 in total):

- [CategoryTree](https://www.mediawiki.org/wiki/Extension:CategoryTree)
- [Cite](https://www.mediawiki.org/wiki/Extension:Cite)
- [CiteThisPage](https://www.mediawiki.org/wiki/Extension:CiteThisPage)
- [CodeEditor](https://www.mediawiki.org/wiki/Extension:CodeEditor)
- [ConfirmEdit](https://www.mediawiki.org/wiki/Extension:ConfirmEdit)
- [Gadgets](https://www.mediawiki.org/wiki/Extension:Gadgets)
- [ImageMap](https://www.mediawiki.org/wiki/Extension:ImageMap)
- [InputBox](https://www.mediawiki.org/wiki/Extension:InputBox)
- [Interwiki](https://www.mediawiki.org/wiki/Extension:Interwiki)
- [LocalisationUpdate](https://www.mediawiki.org/wiki/Extension:LocalisationUpdate)
- [MultimediaViewer](https://www.mediawiki.org/wiki/Extension:MultimediaViewer)
- [Nuke](https://www.mediawiki.org/wiki/Extension:Nuke)
- [OATHAuth](https://www.mediawiki.org/wiki/Extension:OATHAuth)
- [ParserFunctions](https://www.mediawiki.org/wiki/Extension:ParserFunctions)
- [PdfHandler](https://www.mediawiki.org/wiki/Extension:PdfHandler)
- [Poem](https://www.mediawiki.org/wiki/Extension:Poem)
- [Renameuser](https://www.mediawiki.org/wiki/Extension:Renameuser)
- [ReplaceText](https://www.mediawiki.org/wiki/Extension:ReplaceText)
- [SpamBlacklist](https://www.mediawiki.org/wiki/Extension:SpamBlacklist)
- [SyntaxHighlight_GeSHi](https://www.mediawiki.org/wiki/Extension:SyntaxHighlight), depends on Python
- [TitleBlacklist](https://www.mediawiki.org/wiki/Extension:TitleBlacklist)
- [VisualEditor](https://www.mediawiki.org/wiki/Extension:VisualEditor)
- [WikiEditor](https://www.mediawiki.org/wiki/Extension:WikiEditor)

## Usage

The image contains everything required to start a new wiki bundled with the popular VisualEditor extension. It doesn't contain a database, allowing the user to add whatever database he requires to the platform via [docker-compose](https://docs.docker.com/compose/).

### Simple image usage

If you already have a database instance you wish to use, you can just run the wiki using the following Docker command:

```
docker run -d -p 80:80 revianlabs/mediawiki-ve-bundle
```

### Persisting data

If you plan to use this in a production environment, it is highly recommended to use a [Docker volume](https://docs.docker.com/storage/volumes/) for data persistency as follows:

```bash
docker run -d -p 80:80 -v ${PWD}:/var/www/html revianlabs/mediawiki-ve-bundle
```

### Docker Compose usage

Download the `docker-compose.yml` file from this repository:

```yaml
version: '2'
services:
  mariadb:
    image: 'mariadb:10.4.4'
    environment:
      - MYSQL_ROOT_PASSWORD=root_pwd
      - MYSQL_USER=mysql_user
      - MYSQL_PASSWORD=mysql_pwd
      - MYSQL_DATABASE=mysql_database
    volumes:
      - 'mariadb_data:/var/lib/mysql'
  mediawiki:
    image: 'mediawiki-parsoid'
    ports:
      - '8000:80'
    volumes:
      - 'mediawiki_data:/var/www/html'
      - 'parsoid_data:/usr/lib/parsoid'
    depends_on:
      - mariadb
volumes:
  mariadb_data:
    driver: local
  mediawiki_data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/var/www/mediawiki_data'
  parsoid_data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/var/www/parsoid_data'
```

After that, run `docker-compose up -d` to start the services.

Open `http://0.0.0.0/` or `http://127.0.0.1` in your browser, and proceed with the setup process.

:heavy_exclamation_mark: During the setup process, when asked for the Database configuration, be sure you use `mariadb` instead of `localhost` for the database connection URL.

## Upgrade

If you want to use a newer version of images, pull the corresponding image and change image tag in `docker-compose.yml`.
After that, restart the container:

```bash
$ docker-compose up -d --no-deps mediawiki
```

If database migration is needed, run the `upgrade.php` script:

```
$ docker-compose exec mediawiki php /var/www/html/maintenance/update.php
```

## Extensions

Adding extensions is trivial if you're using Docker volumes. Just copy the directory containing the extension into MediaWiki's `extensions` directory, which can be found in the root of the mapped volume.

## License

MIT License