# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: greetings.proto
# Protobuf Python Version: 4.25.0
"""Generated protocol buffer code."""
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import symbol_database as _symbol_database
from google.protobuf.internal import builder as _builder
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()




DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\x0fgreetings.proto\x12\tgreetings\"\x1c\n\x0cHelloRequest\x12\x0c\n\x04name\x18\x01 \x01(\t\"\x1d\n\nHelloReply\x12\x0f\n\x07message\x18\x01 \x01(\t\"\"\n\x0fThankYouRequest\x12\x0f\n\x07message\x18\x01 \x01(\t\"\x1f\n\x0cWelcomeReply\x12\x0f\n\x07message\x18\x01 \x01(\t2\xc6\x01\n\x07Greeter\x12<\n\x08SayHello\x12\x17.greetings.HelloRequest\x1a\x15.greetings.HelloReply\"\x00\x12\x37\n\x05SayHi\x12\x15.greetings.HelloReply\x1a\x15.greetings.HelloReply\"\x00\x12\x44\n\x0bSayThankYou\x12\x1a.greetings.ThankYouRequest\x1a\x17.greetings.WelcomeReply\"\x00\x42]Z[github.com/SmartHobbyjd/greeterservers/go_service/proto/greetingsgo_service/proto/greetingsb\x06proto3')

_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'greetings_pb2', _globals)
if _descriptor._USE_C_DESCRIPTORS == False:
  _globals['DESCRIPTOR']._options = None
  _globals['DESCRIPTOR']._serialized_options = b'Z[github.com/SmartHobbyjd/greeterservers/go_service/proto/greetingsgo_service/proto/greetings'
  _globals['_HELLOREQUEST']._serialized_start=30
  _globals['_HELLOREQUEST']._serialized_end=58
  _globals['_HELLOREPLY']._serialized_start=60
  _globals['_HELLOREPLY']._serialized_end=89
  _globals['_THANKYOUREQUEST']._serialized_start=91
  _globals['_THANKYOUREQUEST']._serialized_end=125
  _globals['_WELCOMEREPLY']._serialized_start=127
  _globals['_WELCOMEREPLY']._serialized_end=158
  _globals['_GREETER']._serialized_start=161
  _globals['_GREETER']._serialized_end=359
# @@protoc_insertion_point(module_scope)
