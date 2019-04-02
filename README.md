# daraja-restful
RESTful extension for the [Daraja HTTP Framework](https://github.com/michaelJustin/daraja-framework)


## How does it work?

Here is a short example, it registers a request handler at path hello which handles HTTP GET requests, but only if the HTTP request also specifies that the client accepts responses with content type text/html. (A HTTP error response will be returned if the HTTP client tries to submit a POST request, or if the client specifies a different content type).

       &Path('hello');
       &Produces('text/html');
       GET
        (procedure(Request: TdjRequest; Response: TdjResponse)
         begin
           Response.ContentText := '<html>Hello world!</html>';
         end);

### Path Parameters

The framework supports path parameters, so that http://mydomain.local/myapp/orders/123 will be routed to this parametrized request handler:

       &Path('orders/{orderId}')
       &Produces('text/html');       
       GET
        (procedure(Request: TdjRequest; Response: TdjResponse)
         begin
           Response.ContentText :=
             Format('<html>Thank you for your order %s</html>',
               [Request.Params.Values['orderId']]);
         end);         

### Multiple Resource Representations

If a resource has more than one representation (HTML, XML or JSON), this can be handled using the same Path value but different MIME type Produces attributes:

       // respond to HTML browsers
       &Path('myresource');
       &Produces('text/html');
       GET(procedure(Request: TdjRequest; Response: TdjResponse)
           begin
             Response.ContentText :=
               '<html>Hello world!</html>';
           end);
        
       // respond to XML client
       &Path('myresource');
       &Produces('application/xml');
       GET(procedure(Request: TdjRequest; Response: TdjResponse)
           begin
             Response.ContentText := '<xml>Hello world!</xml>';
             Response.CharSet := 'utf-8';
       end);
        
       // respond to JSON client
       &Path('myresource');
       &Produces('application/json');
       GET(procedure(Request: TdjRequest; Response: TdjResponse)
           begin
             Response.ContentText := '{"msg":"Hello world!"}';
             Response.CharSet := 'utf-8';
       end);
