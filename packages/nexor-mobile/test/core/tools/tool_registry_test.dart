import 'package:flutter_test/flutter_test.dart';
import 'package:nexor/core/tools/tool_registry.dart';
import 'package:nexor/core/tools/tool.dart';
import 'package:nexor/core/tools/tool_context.dart';
import 'package:nexor/core/tools/tool_result.dart';

// Mock tool for testing
class MockTool extends Tool {
  @override
  String get id => 'mock_tool';

  @override
  String get description => 'A mock tool for testing';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'input': {'type': 'string'},
        },
      };

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    ToolContext context,
  ) async {
    return ToolResult.success(
      title: 'Mock Success',
      output: 'Mock output: ${args['input']}',
    );
  }
}

class FailingMockTool extends Tool {
  @override
  String get id => 'failing_tool';

  @override
  String get description => 'A tool that always fails';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {},
      };

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> args,
    ToolContext context,
  ) async {
    throw Exception('Mock failure');
  }
}

void main() {
  group('ToolRegistry', () {
    late ToolRegistry registry;

    setUp(() {
      registry = ToolRegistry();
    });

    test('should start empty', () {
      expect(registry.count, 0);
      expect(registry.getAllTools(), isEmpty);
    });

    test('should register a tool', () {
      final tool = MockTool();
      registry.register(tool);

      expect(registry.count, 1);
      expect(registry.hasTool('mock_tool'), isTrue);
      expect(registry.getTool('mock_tool'), equals(tool));
    });

    test('should unregister a tool', () {
      final tool = MockTool();
      registry.register(tool);
      registry.unregister('mock_tool');

      expect(registry.count, 0);
      expect(registry.hasTool('mock_tool'), isFalse);
      expect(registry.getTool('mock_tool'), isNull);
    });

    test('should register multiple tools', () {
      registry.register(MockTool());
      registry.register(FailingMockTool());

      expect(registry.count, 2);
      expect(registry.hasTool('mock_tool'), isTrue);
      expect(registry.hasTool('failing_tool'), isTrue);
    });

    test('should get all tools', () {
      registry.register(MockTool());
      registry.register(FailingMockTool());

      final tools = registry.getAllTools();
      expect(tools.length, 2);
      expect(tools.map((t) => t.id), containsAll(['mock_tool', 'failing_tool']));
    });

    test('should get tool definitions for AI', () {
      registry.register(MockTool());

      final definitions = registry.getToolDefinitions();
      expect(definitions.length, 1);
      expect(definitions[0]['name'], 'mock_tool');
      expect(definitions[0]['description'], 'A mock tool for testing');
      expect(definitions[0]['input_schema'], isNotNull);
    });

    test('should execute tool successfully', () async {
      registry.register(MockTool());

      final context = ToolContext(
        sessionId: 'test-session',
        workingDirectory: '/test',
      );

      final result = await registry.executeTool(
        'mock_tool',
        {'input': 'test data'},
        context,
      );

      expect(result.isSuccess, isTrue);
      expect(result.title, 'Mock Success');
      expect(result.output, contains('test data'));
    });

    test('should return error for non-existent tool', () async {
      final context = ToolContext(
        sessionId: 'test-session',
        workingDirectory: '/test',
      );

      final result = await registry.executeTool(
        'non_existent',
        {},
        context,
      );

      expect(result.isSuccess, isFalse);
      expect(result.title, 'Tool not found');
      expect(result.output, contains('non_existent'));
    });

    test('should handle tool execution failure', () async {
      registry.register(FailingMockTool());

      final context = ToolContext(
        sessionId: 'test-session',
        workingDirectory: '/test',
      );

      final result = await registry.executeTool(
        'failing_tool',
        {},
        context,
      );

      expect(result.isSuccess, isFalse);
      expect(result.title, 'Tool execution failed');
      expect(result.output, contains('Mock failure'));
    });

    test('should clear all tools', () {
      registry.register(MockTool());
      registry.register(FailingMockTool());
      registry.clear();

      expect(registry.count, 0);
      expect(registry.getAllTools(), isEmpty);
    });

    test('should replace tool with same id', () {
      final tool1 = MockTool();
      final tool2 = MockTool();

      registry.register(tool1);
      registry.register(tool2);

      expect(registry.count, 1);
      expect(registry.getTool('mock_tool'), equals(tool2));
    });
  });
}
