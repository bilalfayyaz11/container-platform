FROM node:24-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

EXPOSE 3000

RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001 -G appgroup

USER appuser

CMD ["npm", "start"]
