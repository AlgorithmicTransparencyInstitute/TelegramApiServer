# TelegramAPI Server Deployment

1. Deploy
1. `ssh` as ubuntu  onto the server
1. `sudo su -`
1. The following will reset the whole the container and envirement. 
    (Warning, you ll lose all sessions.)
     `rm -rf sessins && docker-compose rm -f -s -v && docker system prune -fa && docker-compose build --no-cache && docker-compose up --force-recreate -d`
