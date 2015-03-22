package com.yp.hugo;

import com.sun.messaging.ConnectionConfiguration;
import com.sun.messaging.ConnectionFactory;
import com.sun.messaging.Queue;

import java.io.*;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageProducer;
import javax.jms.Session;

public class LWESServer {

  public static void main( String[] args ) throws IOException, JMSException {
    ConnectionFactory connFactory = new ConnectionFactory();
    connFactory.setProperty(ConnectionConfiguration.imqAddressList, "localhost:7676");

    Queue myQueue = new Queue("myRemoteQueue");

    try {
      Connection connection = connFactory.createConnection(); 
      connection.start();
      Session session = connection.createSession(true, Session.AUTO_ACKNOWLEDGE); 
      MessageProducer producer = session.createProducer(myQueue);

      System.out.println("Producer Started... ");
      System.out.println("Type your broadcast message:");
      BufferedReader stdin = new BufferedReader( new InputStreamReader(System.in));

      int i = 0;
      while( true ) {
        String quit = stdin.readLine();
        if( quit == null || quit.trim().equals("q") )
          break;
        Message message = session.createTextMessage("this is my test message:" + i);
        producer.setTimeToLive(20L);
        producer.send(message);
        i++;
      }
      producer.close();
      session.close();
      connection.close();
    } catch( Exception e ) {
      throw e;
    }
  }
}

