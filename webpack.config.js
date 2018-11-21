const path = require('path')
const webpack = require('webpack')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')

module.exports = env => {
  return {
    mode: env.production ? 'production' : 'development',
    entry: env.production ? './src/index.ts' : './demo/index.ts',
    output: {
      library: 'simditor',
      libraryTarget: 'umd',
      filename: 'simditor.js',
      path: path.resolve(__dirname, 'dist')
    },
    module: {
      rules: [{
        test: /\.ts$/,
        use: 'ts-loader',
        exclude: /node_modules/
      }, {
        test: /\.scss$/,
        use: ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader']
      }]
    },
    resolve: {
      extensions: ['.ts', '.js', '.json']
    },
    devtool: env.production ? 'source-map' : 'eval-source-map',
    devServer: {
      hot: true
    },
    plugins: [
      new CleanWebpackPlugin(['dist']),
      new HtmlWebpackPlugin({
        title: 'Simditor Demo',
        template: 'demo/index.html'
      }),
      new webpack.HotModuleReplacementPlugin()
    ]
  }
}