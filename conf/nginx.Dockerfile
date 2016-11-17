FROM nginx:stable

RUN touch /var/run/nginx.pid && \
    chown -R www-data:www-data /var/run/nginx.pid \
&&  chown -R www-data:www-data /var/cache/nginx

USER www-data

CMD ["nginx", "-g", "daemon off;"]