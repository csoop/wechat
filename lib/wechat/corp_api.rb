require 'wechat/api_base'
require 'wechat/client'
require 'wechat/access_token'

module Wechat
  class CorpAccessToken < AccessToken
    def refresh
      data = client.get('gettoken', params: { corpid: appid, corpsecret: secret })
      data.merge!(created_at: Time.now.to_i)
      File.write(token_file, data.to_json) if valid_token(data)
      @token_data = data
    end
  end

  class CorpApi < ApiBase
    attr_reader :agentid

    API_BASE = 'https://oapi.dingtalk.com/'

    def initialize(appid, secret, token_file, agentid, skip_verify_ssl)
      @client = Client.new(API_BASE, skip_verify_ssl)
      @access_token = CorpAccessToken.new(@client, appid, secret, token_file)
      @agentid = agentid
    end

    def agent_list
      get 'agent/list'
    end

    def agent(agentid)
      get 'agent/get', params: { agentid: agentid }
    end

    def user(userid)
      get 'user/get', params: { userid: userid }
    end

    def convert_to_openid(userid)
      post 'user/convert_to_openid', JSON.generate(userid: userid, agentid: agentid)
    end

    def invite_user(userid)
      post 'invite/send', JSON.generate(userid: userid)
    end

    def user_auth_success(userid)
      get 'user/authsucc', params: { userid: userid }
    end

    def user_delete(userid)
      get 'user/delete', params: { userid: userid }
    end

    def user_batchdelete(useridlist)
      post 'user/batchdelete', JSON.generate(useridlist: useridlist)
    end

    def batch_job_result(jobid)
      get 'batch/getresult', params: { jobid: jobid }
    end

    def batch_replaceparty(media_id)
      post 'batch/replaceparty', JSON.generate(media_id: media_id)
    end

    def batch_syncuser(media_id)
      post 'batch/syncuser', JSON.generate(media_id: media_id)
    end

    def batch_replaceuser(media_id)
      post 'batch/replaceuser', JSON.generate(media_id: media_id)
    end

    def department_create(name, parentid)
      post 'department/create', JSON.generate(name: name, parentid: parentid)
    end

    def department_delete(departmentid)
      get 'department/delete', params: { id: departmentid }
    end

    def department_update(departmentid, name = nil, parentid = nil, order = nil)
      post 'department/update', JSON.generate({ id: departmentid, name: name, parentid: parentid, order: order }.reject { |_k, v| v.nil? })
    end

    def department(departmentid = 1)
      get 'department/list', params: { id: departmentid }
    end

    def user_simplelist(departmentid, fetch_child = 0, status = 0)
      get 'user/simplelist', params: { departmentid: departmentid, fetch_child: fetch_child, status: status }
    end

    def user_list(departmentid, fetch_child = 0, status = 0)
      get 'user/list', params: { departmentid: departmentid, fetch_child: fetch_child, status: status }
    end

    def tag_create(tagname, tagid = nil)
      post 'tag/create', JSON.generate(tagname: tagname, tagid: tagid)
    end

    def tag_update(tagid, tagname)
      post 'tag/update', JSON.generate(tagid: tagid, tagname: tagname)
    end

    def tag_delete(tagid)
      get 'tag/delete', params: { tagid: tagid }
    end

    def tags
      get 'tag/list'
    end

    def tag(tagid)
      get 'tag/get', params: { tagid: tagid }
    end

    def tag_add_user(tagid, userids = nil, departmentids = nil)
      post 'tag/addtagusers', JSON.generate(tagid: tagid, userlist: userids, partylist: departmentids)
    end

    def tag_del_user(tagid, userids = nil, departmentids = nil)
      post 'tag/deltagusers', JSON.generate(tagid: tagid, userlist: userids, partylist: departmentids)
    end

    def menu
      get 'menu/get', params: { agentid: agentid }
    end

    def menu_delete
      get 'menu/delete', params: { agentid: agentid }
    end

    def menu_create(menu)
      # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码, 这可能是个安全漏洞
      post 'menu/create', JSON.generate(menu), params: { agentid: agentid }
    end

    def media(media_id)
      get 'media/get', params: { media_id: media_id }, as: :file
    end

    def material_count
      get 'material/get_count', params: { agentid: agentid }
    end

    def material_list(type, offset, count)
      post 'material/batchget', JSON.generate(type: type, agentid: agentid, offset: offset, count: count)
    end

    def media_create(type, file)
      post 'media/upload', { upload: { media: file } }, params: { type: type }
    end

    def material(media_id)
      get 'material/get', params: { media_id: media_id, agentid: agentid }, as: :file
    end

    def material_add(type, file)
      post 'material/add_material', { upload: { media: file } }, params: { type: type, agentid: agentid }
    end

    def material_delete(media_id)
      get 'material/del', params: { media_id: media_id, agentid: agentid }
    end

    def message_send(openid, message)
      post 'message/send', Message.to(openid).text(message).agent_id(agentid).to_json, content_type: :json
    end
  end
end
