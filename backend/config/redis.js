module.exports = ({ env }) => ({
  redis: {
    config: {
      host: env('REDIS_HOST'),
      port: env.int('REDIS_PORT'),
    },
  },
});
