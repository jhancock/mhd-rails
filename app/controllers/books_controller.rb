# -*- coding: utf-8 -*-
class BooksController < ApplicationController
  # read by monogo id for backward compatibility
  def read_id
    id = params[:id]
    #book = Book.find(id)
    book = Book.find_for_read_by_id(id)
    @canonical_path = read_book_path(author: book.author, title: book.title) if book
    read_private(book, params[:page])
    #redirect_to read_book_url(author: book.author, title: book.title, page: params[:page]), status: 301
  end

  def read
    author = params[:author]
    title = params[:title]
    # there should only be 1 online book with same author:title pair
    book = Book.online_criteria.find_by(author: author, title: title)
    read_private(book, params[:page])
  end

  def read_private(book, page)
    redirect_to(root_path, status: 301) and return unless book
    #render_404 and return unless book
    @book = book
    @bookmark = current_user ? Bookmark.find_by({user_id: current_user.id, book_id: @book.id}) : nil
    @page = page ? page.to_i : @bookmark ? @bookmark.chunk : 1
    redirect_to read_book_path(author: @book.author, title: @book.title, page: 1) and return if ((@page > @book.chunks) || (@page < 1))

    raise Unauthenticated.new(message: "请先注册后再继续阅读！请确定提供有效邮箱完成注册验证以获得后花园书库免费阅读权限。", redirect_to: register_path, success_path: request.original_fullpath) if @page > 1 && !current_user

    #TODO This check works until I have an option to let them pay.  For the first month, all verified users will be premium.
    raise Unauthorized.new(message: "请验证注册邮箱后继续阅读", redirect_to: email_verify_notice_path) if @page > 2 && !current_user.premium?

    #If user email not verified (they are on page 1 or 2). Show flash message directing them to verify email.  Can't get to page 3 without doing so.
    flash.now[:notice] = "我们已经向您的邮箱 #{current_user.email} 发送了验证邮件，请查收。如果接收邮件有问题，请点击 #{view_context.link_to("请验证注册邮箱", email_verify_notice_path)}，成功后可获得迷蝴蝶后花园一个月免费畅读权限。".html_safe if @page > 1 && !current_user.email_verified?

    begin
      path = @book.chunk_path(@page)
      logger.info "PATH: #{path}"
      @content = IO.read(path).html_safe
    rescue Errno::ENOENT
      @book.set_offline_file_not_found!(path)
      flash[:notice] = "book temporarily offline"
      redirect_to(root_path, status: 301) and return
    end
    @chapter_title = @book.chapter_title(@page)
    @page_title = "#{@chapter_title} #{@book.title} - #{@book.author}"
    @page_description = "#{@chapter_title} #{@book.title} #{@book.author} 在线阅读最吸引人的中文电子书"
    @page_keywords = "#{@book.tag_names_pp} #{@chapter_title} #{@book.title} #{@book.author} 关注 流行 中文电子书 在线阅读"

    @book.increment_read_count if !current_user || !current_user.admin?
    @book.increment_unique_read_count if current_user && !@bookmark
    Bookmark.set(current_user, @book, @page) if current_user
    begin
      render "read", layout: "reading"
    rescue ActionView::Template::Error
      @book.set_offline_invalid_coding!(@page)
      flash[:notice] = "book temporarily offline"
      redirect_to(root_path, status: 301) and return
    end
  end

  def list
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @sort = params[:sort] || 'popular'
    criteria = Book.online_popular if @sort == "popular"
    criteria = Book.online_recent if @sort == "recent"
    @books = criteria.page(@page)
    @page_title = "#{list_view_page_prefix(@page)} #{sort_cn(@sort)} 电子书在线阅读"
    #@page_title = "关注排行 电子书在线阅读"
    #TODO
    @page_description = "按近期被点击次数排行和最新更新排行的电子书，在线阅读最新最吸引人的中文电子书"
    @page_keywords = "关注 最新 流行 中文电子书 手机阅读 在线阅读 全本下载"
  end

  def tag
    @page = params[:page].to_i > 0 ? params[:page].to_i : 1
    @tag = GenreTag.by_name(params[:tag])
    redirect_to(root_path, status: 301, notice: "tag #{@tag} does not exist") and return unless @tag
    @sort = params[:sort] || 'popular'
    criteria = Book.online_popular_by_tag(@tag) if @sort == "popular"
    criteria = Book.online_recent_by_tag(@tag) if @sort == "recent"
    @books = criteria.page(@page)
    @page_title = "#{list_view_page_prefix(@page)} #{@tag.cn} #{sort_cn(@sort)} 电子书在线阅读"
    @page_description = "#{@tag.cn} 的言情小说在此应有尽有，最热门，最新，最全类型的原创作品均在此陈列。喜欢此类故事的朋友一定能在此找到自己喜爱的书籍"
    @page_keywords = "#{@tag.cn}  言情小说  耽美小说 同人小说 电子书  在线阅读 全本下载"
  end

end
