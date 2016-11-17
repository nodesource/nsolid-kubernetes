FROM nginx:stable

RUN touch /var/run/nginx.pid \
 && chown -R www-data:root /var/run/nginx.pid \
 && chmod -R 0770 /var/run/nginx.pid \
 && chown -R www-data:root /var/cache/nginx \
 && chmod -R 0770 /var/cache/nginx;

USER www-data

CMD ["nginx", "-g", "daemon off;"]