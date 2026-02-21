function set_tabpfn_access_token(access_token)
% SET_TABPFN_ACCESS_TOKEN Set the access token for the TabPFN API.
%   set_tabpfn_access_token(TOKEN) sets the access token string required
%   to authenticate with the TabPFN cloud service.
%
%   Get your token at: https://ux.priorlabs.ai/account
%
%   Example:
%     set_tabpfn_access_token('your-token-here')

    arguments
        access_token (1,1) string
    end

    tabpfn = py.importlib.import_module('tabpfn_client');
    tabpfn.set_access_token(char(access_token));
    fprintf('Access token has been set.\n');
end
