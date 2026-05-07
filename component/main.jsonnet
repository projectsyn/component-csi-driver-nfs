// main template for csi-driver-nfs
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.csi_driver_nfs;

local isOpenshift = std.member([ 'openshift4', 'oke' ], inv.parameters.facts.distribution);

local sccRBAC = [
  kube.RoleBinding('scc-privileged') {
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'ClusterRole',
      name: 'system:openshift:scc:privileged',
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: params.controller.serviceAccountName,
      },
      {
        kind: 'ServiceAccount',
        name: params.node.serviceAccountName,
      },
    ],
  },
];

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
  [if isOpenshift then '02_scc_rbac']: sccRBAC,
}
