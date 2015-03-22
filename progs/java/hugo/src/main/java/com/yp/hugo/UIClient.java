package com.yp.hugo;

import com.sun.messaging.ConnectionConfiguration;
import com.sun.messaging.ConnectionFactory;
import com.sun.messaging.Queue;
import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.Session;
import javax.jms.TextMessage;

public class UIClient {

  public static void main( String[] args ) throws JMSException {
    ConnectionFactory connFactory = new ConnectionFactory();
    connFactory.setProperty(ConnectionConfiguration.imqAddressList, "localhost:7676");

    Queue myQueue = new Queue("myRemoteQueue");

    try {
      System.out.println("Consumer listening... ");
      Connection connection = connFactory.createConnection(); 
      connection.start();
      Session session = connection.createSession(true, Session.AUTO_ACKNOWLEDGE); 
      MessageConsumer consumer = session.createConsumer(myQueue);

      //while( true ) {
        Message message = consumer.receive();
        if (message instanceof TextMessage) {
            TextMessage textMessage = (TextMessage) message;
            String text = textMessage.getText();
            System.out.println("Text Message Received: " + text);
        } else {
            System.out.println("Message Received: " + message);
        }
       // if( message == null || message.toString().trim().equals("q")) {
         // break;
        //}
      //}
      consumer.close();
      session.close();
      connection.close();
    } catch( Exception e ) {
      throw e;
    }
  }
}
