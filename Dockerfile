FROM registry.access.redhat.com/ubi8/openjdk-17-runtime:1.17
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN echo 'package com.example.chatapp; import java.io.*; import java.net.*; public class SimpleServer { public static void main(String[] args) throws Exception { ServerSocket ss = new ServerSocket(8080); System.out.println("Server running on port 8080"); while(true) { Socket s = ss.accept(); PrintWriter out = new PrintWriter(s.getOutputStream()); out.println("HTTP/1.1 200 OK\\r\\nContent-Type: text/html\\r\\n\\r\\n<h1>Hello from ChatApp!</h1><p>App is running.</p>"); out.close(); s.close(); }}}' > SimpleServer.java && \
    javac SimpleServer.java && \
    jar cfe app.jar com.example.chatapp.SimpleServer *.class
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
