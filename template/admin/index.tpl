
<section class="admin-main">
    <div class="container-fluid">
        <div class="page-container">
            <div class="card">
                <div class="card-body">
                    <!-- class="col-lg-1 col-md-12 col-sm-12" -->
                    <div class="card-title row">
                        <div class="pl-4 pr-4">{$Title}</div>
                        <div class="col-lg-8 col-md-12 col-sm-12">
                            {foreach $PluginsAdminMenu as $v}
                                {if $v['custom']}
                                    <span  class="ml-2"><a  class="h5" href="{$v.url}" target="_blank">{$v.name}</a></span>
                                {else/}
                                    <span  class="ml-2"> <a  class="h5" href="{$v.url}">{$v.name}</a></span>
                                {/if}
                            {/foreach}
                        </div>
                    </div>

                    <div class="tab-content mt-4">


                        <div class="table-body auto-login-content" style="margin-top: 10px;">
                            <table class="table table-bordered table-hover activity-table">
                                <thead class="thead-light">
                                <tr>

                                    <th>上游ID </th>

                                    <th>上游名称</th>

                                    <th>操作</th>
                                </tr>
                                </thead>
                                <tbody>
                                {foreach $List as $key=>$item}
                                    <tr data-data='{$item|json_encode}'>
                                        <td class="center">{$item.id}</td>



                                        <td>{$item.name}</td>


                                        <td>
                                            <a href="addons?_plugin={$GzhxPluginPath}&_controller=admin_index&_action=set&id={$item.id}" class="btn btn-link get-md5 edit"><i class="fas fa-edit"></i> 一键同步产品</a>
                                        </td>
                                    </tr>
                                {/foreach}
                                </tbody>
                            </table>
                        </div>

        
                        <div class="table-body" id="renewMsg" style="color: #ff0000;"></div>

                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
