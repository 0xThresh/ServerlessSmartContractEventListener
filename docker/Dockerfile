FROM node:16.17
RUN ["mkdir", "/opt/event-listener"]
COPY ./* /opt/event-listener
WORKDIR /opt/event-listener
RUN ["npm", "i", "axios@1.3.3", "ethers@5.7.2", "aws-sdk@2.1319.0"]
CMD ["node", "/opt/event-listener/eventListener.ts"]
