#include <iostream>

// This is the first gcc header to be included
#include "gcc-plugin.h"
#include "plugin-version.h"

#include "tree-pass.h"
#include "context.h"
#include "function.h"
#include "tree.h"
#include "tree-ssa-alias.h"
#include "internal-fn.h"
#include "is-a.h"
#include "predict.h"
#include "basic-block.h"
#include "gimple-expr.h"
#include "gimple.h"
#include "gimple-pretty-print.h"
#include "gimple-iterator.h"
#include "gimple-walk.h"

#include "analyzer-pass.h"

// We must assert that this plugin is GPL compatible
int plugin_is_GPL_compatible;

static struct plugin_info my_gcc_plugin_info = { "1.0", "huatuo is a doctor for your code." };

void
parser_arguments(struct plugin_name_args *plugin_info)
{
  for (int i = 0; i < plugin_info->argc; i++)
    {
        std::cerr << "Argument " << i
		  << ": Key: " << plugin_info->argv[i].key
		  << ". Value: " << plugin_info->argv[i].value << "\n";
    }
}

int plugin_init (struct plugin_name_args *plugin_info,
		struct plugin_gcc_version *version)
{
  // We check the current gcc loading this plugin against the gcc we used to
  // created this plugin
  if (!plugin_default_version_check (version, &gcc_version))
    {
        std::cerr << "This GCC plugin is for version "
		  << GCCPLUGIN_VERSION_MAJOR << "."
		  << GCCPLUGIN_VERSION_MINOR << "\n";
	return 1;
    }

  parser_arguments(plugin_info);
  
  register_callback(plugin_info->base_name,
            /* event */ PLUGIN_INFO,
            /* callback */ NULL, /* user_data */ &my_gcc_plugin_info);

  // Register the phase right after cfg
  struct register_pass_info pass_info;
  pass_info.pass = make_pass_huatuo_analyzer(g);
  pass_info.reference_pass_name = "analyzer";
  pass_info.ref_pass_instance_number = 1;
  pass_info.pos_op = PASS_POS_INSERT_AFTER;

  register_callback (plugin_info->base_name, PLUGIN_PASS_MANAGER_SETUP, NULL, &pass_info);

  return 0;
}
