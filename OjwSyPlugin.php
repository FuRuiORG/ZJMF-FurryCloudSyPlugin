<?php
namespace addons\ojw_sy;

class OjwSyPlugin extends \app\admin\lib\Plugin
{
    public $info = ["name" => "OjwSy", "title" => "FurryCloud一键同步上游修复版", "description" => "一键同步上游产品", "status" => 1, "author" => "Aria", "version" => "1.0", "module" => "addons", "update_description" => "一键同步上游产品", "not_install" => true];
    public function install(): bool
    {
        return true;
    }
    public function uninstall()
    {
        return true;
    }
}

?>