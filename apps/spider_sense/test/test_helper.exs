ExUnit.start()

require Hammox
Hammox.defmock(TracerMock, for: SpiderSense.DExplorer.Tracer.Behaviour)
