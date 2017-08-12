# gdc-sigma.github.io

This is the repository for the official blog site of GDC Sigma team. [http://gdc-sigma.com/](http://gdc-sigma.com/)

## Writing New Post

To write a new post, create a new Markdown file in `source/_posts`. You can check other posts' `.md` files for reference.

After you test your post locally, you can commit your changes and push the commit to the `source` branch of `origin`. The blog will be automatically built and deployed to [http://gdc-sigma.com/](http://gdc-sigma.com/) by Travis.

## Set Up Environment

The GDC Sigma blog is built by using [Hexo](https://hexo.io/).

### Docker

The repository comes with a `Dockerfile`. It can be used to set up development environment immediately if you had docker installed on your machine:

```bash
# Build docker image
docker build -t sigma-blog .

# Start docker containter
docker run -it --name sigma-blog -h sigma-blog -v .:/sigma-blog -p 4000:4000 sigma-blog
```

After executing the above commands, the Hexo server should be running at foreground, which can be stopped by pressing `CTRL+C`.

After you set up the Docker container, next time you can start the container directly by executing the following command:

```bash
docker start -i sigma-blog
```

Note that the Hexo server's fs watching might not work in Docker container. If so, please manually restart the Docker container every time you change your post.

### Native NPM

If you prefered to run Hexo on your machine directly, you can use the following commands to install the dependencies:

```bash
# Install hexo-cli
npm install -g hexo-cli

# Install dependencies
npm install

# Start Hexo server
hexo server
```

## Contacts

- Official Email: `gdcsigmaer@gmail.com`
