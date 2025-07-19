# SSL Setup

This guide covers setting up SSL/TLS certificates for HTTPS on your Rails Blueprint application using Let's Encrypt and Certbot.

## Overview

SSL/TLS provides:
- **Encrypted connections** - Protects user data
- **Authentication** - Verifies your server identity  
- **SEO benefits** - Google prefers HTTPS sites
- **Browser trust** - No security warnings
- **HTTP/2 support** - Better performance

## Prerequisites

- Domain name pointing to your server
- Nginx installed and configured
- Port 80 and 443 open in firewall
- Root or sudo access

## Let's Encrypt Setup

### 1. Install Certbot

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Verify installation
certbot --version
```

### 2. Obtain Certificate

```bash
# For single domain
sudo certbot --nginx -d example.com -d www.example.com

# For staging environment
sudo certbot --nginx -d staging.example.com

# Follow prompts:
# - Enter email for renewal notices
# - Agree to terms
# - Choose whether to redirect HTTP to HTTPS (recommended)
```

### 3. Verify Installation

```bash
# Check certificate
sudo certbot certificates

# Test renewal
sudo certbot renew --dry-run

# Check nginx configuration
sudo nginx -t
sudo systemctl reload nginx
```

## Nginx Configuration

### Basic SSL Configuration

After Certbot, your nginx config will include:

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    
    # Redirect all HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    # SSL certificates (managed by Certbot)
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    # Rails application
    root /home/deploy/apps/myapp/current/public;
    
    location / {
        try_files $uri @app;
    }
    
    location @app {
        proxy_pass http://unix:/home/deploy/apps/myapp/shared/tmp/sockets/puma.sock;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }
}
```

### Enhanced Security Configuration

Add these security headers:

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Basic SSL config...
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; img-src 'self' data: https:; font-src 'self' data: https://cdn.jsdelivr.net; connect-src 'self' wss:;" always;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;
    
    # Session configuration
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    
    # Modern cipher configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
}
```

## Rails Configuration

### 1. Force SSL in Production

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Force all access to the app over SSL
  config.force_ssl = true
  
  # Exclude health check endpoint
  config.ssl_options = { 
    redirect: { 
      exclude: -> request { request.path =~ /health/ } 
    },
    hsts: {
      expires: 1.year,
      subdomains: true,
      preload: true
    }
  }
end
```

### 2. Update URL Configuration

```ruby
# config/environments/production.rb
config.action_mailer.default_url_options = { 
  host: 'example.com',
  protocol: 'https'
}

# config/app.yml
production:
  protocol: 'https'
  domain: 'example.com'
```

### 3. Cookie Security

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store, 
  key: '_myapp_session',
  secure: Rails.env.production?, # Cookies only over HTTPS
  httponly: true,               # Not accessible via JavaScript
  same_site: :lax              # CSRF protection
```

## Certificate Renewal

### Automatic Renewal

Certbot sets up automatic renewal via systemd timer:

```bash
# Check timer status
sudo systemctl status certbot.timer

# View timer schedule
sudo systemctl list-timers

# Manual renewal
sudo certbot renew
```

### Renewal Hooks

Add nginx reload to renewal:

```bash
# Create renewal hook
sudo nano /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh

#!/bin/bash
systemctl reload nginx

# Make executable
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
```

### Monitor Renewals

```bash
# Check certificate expiration
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates

# Set up email alerts in crontab
0 9 * * 1 certbot certificates 2>&1 | mail -s "Certificate Status" admin@example.com
```

## Multiple Domains

### Wildcard Certificates

For subdomains:

```bash
# DNS challenge required for wildcards
sudo certbot certonly --manual --preferred-challenges dns -d "*.example.com" -d example.com

# Add TXT record as instructed
# Verify DNS propagation before continuing
```

### Multiple Certificates

```nginx
# Staging environment
server {
    listen 443 ssl http2;
    server_name staging.example.com;
    
    ssl_certificate /etc/letsencrypt/live/staging.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/staging.example.com/privkey.pem;
    
    # Rest of config...
}

# Production environment  
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # Rest of config...
}
```

## Testing SSL

### Online Tools

1. **SSL Labs Test**: https://www.ssllabs.com/ssltest/
   - Comprehensive analysis
   - Grade your configuration
   - Browser compatibility

2. **Security Headers**: https://securityheaders.com/
   - Check security headers
   - Recommendations for improvements

### Command Line Tests

```bash
# Test SSL connection
openssl s_client -connect example.com:443 -servername example.com

# Check certificate details
curl -vI https://example.com

# Test specific TLS version
openssl s_client -connect example.com:443 -tls1_2

# Verify certificate chain
openssl s_client -connect example.com:443 -showcerts
```

## Troubleshooting

### Common Issues

1. **Certificate Not Trusted**
   ```bash
   # Check certificate chain
   sudo certbot certificates
   
   # Ensure fullchain.pem is used, not cert.pem
   ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
   ```

2. **Mixed Content Warnings**
   ```bash
   # Find non-HTTPS resources
   grep -r "http://" app/views/
   grep -r "http://" app/assets/
   
   # Use protocol-relative URLs
   # Instead of: http://example.com/asset.js
   # Use: //example.com/asset.js
   ```

3. **Redirect Loops**
   ```nginx
   # Ensure Rails knows about SSL
   proxy_set_header X-Forwarded-Proto $scheme;
   proxy_set_header X-Forwarded-Ssl on;
   ```

4. **Certificate Renewal Failed**
   ```bash
   # Check logs
   sudo journalctl -u certbot
   
   # Test renewal
   sudo certbot renew --dry-run
   
   # Check nginx config
   sudo nginx -t
   ```

### Debug Mode

```bash
# Verbose Certbot output
sudo certbot renew --dry-run -v

# Test nginx SSL config
sudo nginx -T | grep -A 10 "ssl_"

# Check Rails SSL redirect
curl -I http://example.com
# Should show: Location: https://example.com/
```

## Advanced Configuration

### HTTP/2 Push

```nginx
location ~* \.(js|css)$ {
    http2_push_preload on;
    add_header Link "</assets/application.css>; rel=preload; as=style" always;
}
```

### OCSP Must-Staple

```bash
# Request certificate with must-staple
sudo certbot certonly --nginx -d example.com --must-staple
```

### CAA Records

Add DNS CAA records for additional security:

```
example.com. CAA 0 issue "letsencrypt.org"
example.com. CAA 0 iodef "mailto:admin@example.com"
```

## Monitoring

### Certificate Expiration

```bash
# Script to check expiration
#!/bin/bash
DOMAIN="example.com"
EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt 30 ]; then
    echo "Certificate expires in $DAYS_LEFT days!"
    # Send alert
fi
```

### SSL Monitoring Services

- UptimeRobot - Free SSL monitoring
- Pingdom - Advanced SSL checks
- New Relic - Application and SSL monitoring

## Best Practices

1. **Always use HTTPS** - Even in staging
2. **Strong ciphers only** - Disable weak protocols
3. **HSTS preloading** - Add to browser lists
4. **Monitor expiration** - Set up alerts
5. **Test after changes** - Use SSL Labs
6. **Backup certificates** - Before renewal
7. **Security headers** - Implement all recommended headers

## Next Steps

- Test your SSL configuration at SSL Labs
- Set up monitoring for certificate expiration
- Configure security headers
- Review [environment configuration](environments.md)