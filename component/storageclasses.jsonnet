local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local sc = import 'lib/storageclass.libsonnet';

local inv = kap.inventory();
local params = inv.parameters.csi_driver_nfs;

local scDefaults = params.storageClassDefaults;
// get provisioner name from Helm values, falling back on driver default of
// `nfs.csi.k8s.io`.
local provisionerName =
  std.get(
    params.helmValues, 'driver', { name: 'nfs.csi.k8s.io' }
  ).name;

local storageclasses = std.map(
  function(sc)
    if
      !std.objectHas(sc, 'parameters') ||
      !std.isObject(sc.parameters) ||
      !std.objectHas(sc.parameters, 'server') ||
      !std.objectHas(sc.parameters, 'share')
    then
      error 'StorageClass "%s" for NFS CSI driver is invalid: one or more of `parameters.server` and `parameters.share` are missing!' % [ sc.metadata.name ]
    else
      sc {
        provisioner: provisionerName,
      },
  com.generateResources(
    params.storageClasses,
    function(name) sc.storageClass(name) + com.makeMergeable(scDefaults)
  )
);


{
  [if std.length(storageclasses) > 0 then '50_storageclasses']: storageclasses,
}
