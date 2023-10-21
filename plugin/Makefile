
PLUGIN=huatuo-analyzer.so
SOURCES=\
		plugin-manager.cc \
	        analyzer-pass.cc \
		engine.cc \
		analysis-plan.cc \
		analyzer-logging.cc \
		analyzer.cc \
		bar-chart.cc \
		call-info.cc \
		call-string.cc \
		checker-path.cc \
		complexity.cc \
		constraint-manager.cc \
		diagnostic-manager.cc \
		feasible-graph.cc \
		function-set.cc \
		pending-diagnostic.cc \
		program-point.cc \
		program-state.cc \
		region-model-asm.cc \
		region-model-impl-calls.cc \
		region-model-manager.cc \
		region-model-reachability.cc \
		region-model.cc \
		region.cc \
		sm-file.cc \
		sm-malloc.cc \
		sm-pattern-test.cc \
		sm-sensitive.cc \
		sm-signal.cc \
		sm-taint.cc \
		sm.cc \
		state-purge.cc \
		store.cc \
		supergraph.cc \
		svalue.cc \
		trimmed-graph.cc \
		$(END)

include ./Makefile.common

.PHONY: test
test: $(PLUGIN)
	$(CCPLUGIN) -c -o /dev/null ./testsuit/analyzer-verbosity-0.c
