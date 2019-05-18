const Sequelize = require('sequelize')
const localconf = require('./local.js')

let sequelize = new Sequelize(localconf.connectionString, {
  dialect: 'postgres',
  protocol: 'postgres',
  dialectOptions: {
    ssl: true
  },
  define: {
    timestamps: false
  },
})

module.exports = sequelize
