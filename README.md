# daraja-restful
RESTful extension for the [Daraja Framework](https://github.com/michaelJustin/daraja-framework)


## How does it work?

Here is a short example, it registers a request handler at path hello which handles HTTP GET requests, but only if the HTTP request also specifies that the client accepts responses with content type text/html. (A HTTP error response will be returned if the HTTP client tries to submit a POST request, or if the client specifies a different content type).

       &Path('hello');
       &Produces('text/html');
       GET
        (procedure(Request: TRequest; Response: TResponse)
         begin
           Response.ContentText := '<html>Hello world!</html>';
         end);

### Path Parameters

The framework supports path parameters, so that http://mydomain.local/myapp/orders/123 will be routed to this parametrized request handler:

       &Path('orders/{orderId}')
       GET
        (procedure(Request: TRequest; Response: TResponse)
         begin
           Response.ContentText :=
             Format('<html>Thank you for your order %s</html>',
               [Request.Params.Values['orderId']]);
         end);         
