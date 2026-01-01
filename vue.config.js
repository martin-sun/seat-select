const { defineConfig } = require('@vue/cli-service')
const path = require('path')

module.exports = defineConfig({
  // 基本路径
  publicPath: '/',
  // 如果您不需要生产时的源映射，那么将此设置为false可以加速生产构建
  productionSourceMap: false,
  transpileDependencies: true,
  css: {
    loaderOptions: {
      stylus: {
        // stylus-loader 7.x 需要使用 stylusOptions
      }
    }
  },
  chainWebpack: config => {
    const types = ['vue-modules', 'vue', 'normal-modules', 'normal']
    types.forEach(type => addStyleResource(config.module.rule('stylus').oneOf(type)))
  },
  devServer: {
    proxy: {
      '/mock': {
        target: 'http://localhost:80',
        pathRewrite: {
          '^/mock': '/mock'
        }
      }
    }
  }
})

function addStyleResource (rule) {
  rule.use('style-resource')
    .loader('style-resources-loader')
    .options({
      patterns: [
        path.resolve(__dirname, './src/assets/stylus/golbal.styl')
      ]
    })
}
