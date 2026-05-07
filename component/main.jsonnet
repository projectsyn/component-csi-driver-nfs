// main template for csi-driver-nfs
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.csi_driver_nfs;

// Define outputs below
{
  '00_namespace': kube.Namespace(params.namespace) {
    metadata+: {
      annotations: {
        'openshift.io/node-selector': '',
      },
      labels: {
        'openshift.io/cluster-monitoring': 'true',
      },
    },
  },
}
