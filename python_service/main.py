from concurrent import futures
import grpc
import greetings_pb2
import greetings_pb2_grpc

class Greeter(greetings_pb2_grpc.GreeterServicer):

    def SayHello(self, request, context):
        return greetings_pb2.HelloReply(message='Hi from Python')

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    greetings_pb2_grpc.add_GreeterServicer_to_server(Greeter(), server)
    server.add_insecure_port('[::]:50053')
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
