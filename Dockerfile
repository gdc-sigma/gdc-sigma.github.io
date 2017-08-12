FROM node

RUN npm config set user 0
RUN npm config set unsafe-perm true
RUN npm install -g hexo-cli

ADD docker-entrypoint.sh /root/
ENV SIGMA_BLOG_DOCKER 1

VOLUME /sigma-blog
WORKDIR /sigma-blog

EXPOSE 4000

CMD ["/root/docker-entrypoint.sh"]
