local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.csi_driver_nfs;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('csi-driver-nfs', params.namespace);

local appPath =
  local project = std.get(std.get(app, 'spec', {}), 'project', 'syn');
  if project == 'syn' then 'apps' else 'apps-%s' % project;

{
  ['%s/csi-driver-nfs' % appPath]: app,
}
