#ifndef GCC_ANALYZER_ANALYZER_PASS_H
#define GCC_ANALYZER_ANALYZER_PASS_H

#include "config.h"
#include "system.h"
#include "coretypes.h"
#include "context.h"
#include "tree-pass.h"
#include "diagnostic.h"
#include "options.h"
#include "tree.h"
#include "function.h"
#include "analyzer.h"
#include "engine.h"

ipa_opt_pass_d *make_pass_huatuo_analyzer (gcc::context *ctxt);

#endif // GCC_ANALYZER_ANALYZER_PASS_H