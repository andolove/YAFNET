/* Version 0.9.2 */

if not exists(select * from syscolumns where id=object_id('yaf_System') and name='AllowRichEdit')
	alter table yaf_System add AllowRichEdit bit null
GO

update yaf_System set AllowRichEdit=1 where AllowRichEdit is null
GO

alter table yaf_System alter column AllowRichEdit bit not null
GO

if not exists(select * from syscolumns where id=object_id('yaf_System') and name='AllowUserTheme')
	alter table yaf_System add AllowUserTheme bit null
GO

update yaf_System set AllowUserTheme=0 where AllowUserTheme is null
GO

alter table yaf_System alter column AllowUserTheme bit not null
GO

if not exists(select * from syscolumns where id=object_id('yaf_System') and name='AllowUserLanguage')
	alter table yaf_System add AllowUserLanguage bit null
GO

update yaf_System set AllowUserLanguage=0 where AllowUserLanguage is null
GO

alter table yaf_System alter column AllowUserLanguage bit not null
GO

if not exists(select * from syscolumns where id=object_id('yaf_User') and name='LanguageFile')
	alter table yaf_User add LanguageFile varchar(50) null
GO

if not exists(select * from syscolumns where id=object_id('yaf_User') and name='ThemeFile')
	alter table yaf_User add ThemeFile varchar(50) null
GO

if not exists(select * from sysobjects where name='FK_Attachment_Message' and parent_obj=object_id('yaf_Attachment') and OBJECTPROPERTY(id,N'IsForeignKey')=1)
ALTER TABLE [yaf_Attachment] ADD 
	CONSTRAINT [FK_Attachment_Message] FOREIGN KEY 
	(
		[MessageID]
	) REFERENCES [yaf_Message] (
		[MessageID]
	)
GO

-- NNTP START
if not exists (select * from sysobjects where id = object_id(N'yaf_NntpServer') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
create table yaf_NntpServer(
	[NntpServerID]	[int] identity not null,
	[Name]			[varchar](50) not null,
	[Address]		[varchar](100) not null,
	[UserName]		[varchar](50) null,
	[UserPass]		[varchar](50) null
)
GO

if not exists(select * from sysindexes where id=object_id('yaf_NntpServer') and name='PK_NntpServer')
ALTER TABLE [yaf_NntpServer] WITH NOCHECK ADD 
	CONSTRAINT [PK_NntpServer] PRIMARY KEY  CLUSTERED 
	(
		[NntpServerID]
	) 
GO

if not exists (select * from sysobjects where id = object_id(N'yaf_NntpForum') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
create table yaf_NntpForum(
	[NntpForumID]	[int] identity not null,
	[NntpServerID]	[int] not null,
	[GroupName]		[varchar](100) not null,
	[ForumID]		[int] not null,
	[LastMessageNo]	[int] not null,
	[LastUpdate]	[datetime] not null
)
GO

if not exists(select * from sysindexes where id=object_id('yaf_NntpForum') and name='PK_NntpForum')
ALTER TABLE [yaf_NntpForum] WITH NOCHECK ADD 
	CONSTRAINT [PK_NntpForum] PRIMARY KEY  CLUSTERED 
	(
		[NntpForumID]
	) 
GO

if not exists(select * from sysobjects where name='FK_NntpForum_NntpServer' and parent_obj=object_id('yaf_NntpForum') and OBJECTPROPERTY(id,N'IsForeignKey')=1)
ALTER TABLE [yaf_NntpForum] ADD 
	CONSTRAINT [FK_NntpForum_NntpServer] FOREIGN KEY 
	(
		[NntpServerID]
	) REFERENCES [yaf_NntpServer] (
		[NntpServerID]
	)
GO

if not exists(select * from sysobjects where name='FK_NntpForum_Forum' and parent_obj=object_id('yaf_NntpForum') and OBJECTPROPERTY(id,N'IsForeignKey')=1)
ALTER TABLE [yaf_NntpForum] ADD 
	CONSTRAINT [FK_NntpForum_Forum] FOREIGN KEY 
	(
		[ForumID]
	) REFERENCES [yaf_Forum] (
		[ForumID]
	)
GO

if not exists (select * from sysobjects where id = object_id(N'yaf_NntpTopic') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
create table yaf_NntpTopic(
	[NntpTopicID]		[int] identity not null,
	[NntpForumID]		[int] not null,
	[Thread]			[char](32) not null,
	[TopicID]			[int] not null
)
GO

if not exists(select * from sysindexes where id=object_id('yaf_NntpTopic') and name='PK_NntpTopic')
ALTER TABLE [yaf_NntpTopic] WITH NOCHECK ADD 
	CONSTRAINT [PK_NntpTopic] PRIMARY KEY  CLUSTERED 
	(
		[NntpTopicID]
	) 
GO

if not exists(select * from sysobjects where name='FK_NntpTopic_NntpForum' and parent_obj=object_id('yaf_NntpTopic') and OBJECTPROPERTY(id,N'IsForeignKey')=1)
ALTER TABLE [yaf_NntpTopic] ADD 
	CONSTRAINT [FK_NntpTopic_NntpForum] FOREIGN KEY 
	(
		[NntpForumID]
	) REFERENCES [yaf_NntpForum] (
		[NntpForumID]
	)
GO

if not exists(select * from sysobjects where name='FK_NntpTopic_Topic' and parent_obj=object_id('yaf_NntpTopic') and OBJECTPROPERTY(id,N'IsForeignKey')=1)
ALTER TABLE [yaf_NntpTopic] ADD 
	CONSTRAINT [FK_NntpTopic_Topic] FOREIGN KEY 
	(
		[TopicID]
	) REFERENCES [yaf_Topic] (
		[TopicID]
	)
GO

if exists (select * from sysobjects where id = object_id(N'yaf_nntpforum_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_nntpforum_list
GO

create procedure yaf_nntpforum_list(@Minutes int=null,@NntpForumID int=null) as
begin
	select
		a.Name,
		a.Address,
		a.NntpServerID,
		b.NntpForumID,
		b.GroupName,
		b.ForumID,
		b.LastMessageNo,
		ForumName = c.Name
	from
		yaf_NntpServer a,
		yaf_NntpForum b,
		yaf_Forum c
	where
		b.NntpServerID = a.NntpServerID and
		(@Minutes is null or datediff(n,b.LastUpdate,getdate())>@Minutes) and
		(@NntpForumID is null or b.NntpForumID=@NntpForumID) and
		c.ForumID = b.ForumID
	order by
		a.Name,
		b.GroupName
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_nntptopic_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_nntptopic_list
GO

create procedure yaf_nntptopic_list(@Thread char(32)) as
begin
	select
		a.*
	from
		yaf_NntpTopic a
	where
		a.Thread = @Thread
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_nntpforum_update') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_nntpforum_update
GO

create procedure yaf_nntpforum_update(@NntpForumID int,@LastMessageNo int) as
begin
	update yaf_NntpForum set
		LastMessageNo = @LastMessageNo,
		LastUpdate = getdate()
	where NntpForumID = @NntpForumID
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_nntptopic_save') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_nntptopic_save
GO

create procedure yaf_nntptopic_save(@NntpForumID int,@Thread char(32),@TopicID int) as
begin
	insert into yaf_NntpTopic(NntpForumID,Thread,TopicID)
	values(@NntpForumID,@Thread,@TopicID)
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_nntpserver_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_nntpserver_list
GO

create procedure yaf_nntpserver_list(@NntpServerID int=null) as
begin
	if @NntpServerID is null
		select * from yaf_NntpServer order by Name
	else
		select * from yaf_NntpServer where NntpServerID=@NntpServerID
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_nntpserver_save') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_nntpserver_save
GO

create procedure yaf_nntpserver_save(
	@NntpServerID 	int=null,
	@Name		varchar(50),
	@Address	varchar(100),
	@UserName	varchar(50)=null,
	@UserPass	varchar(50)=null
) as begin
	if @NntpServerID is null
		insert into yaf_NntpServer(Name,Address,UserName,UserPass)
		values(@Name,@Address,@UserName,@UserPass)
	else
		update yaf_NntpServer set
			Name = @Name,
			Address = @Address,
			UserName = @UserName,
			UserPass = @UserPass
		where NntpServerID = @NntpServerID
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_nntpserver_delete') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_nntpserver_delete
GO

create procedure yaf_nntpserver_delete(@NntpServerID int) as
begin
	delete from yaf_NntpServer where NntpServerID = @NntpServerID
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_nntpforum_save') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_nntpforum_save
GO

create procedure yaf_nntpforum_save(@NntpForumID int=null,@NntpServerID int,@GroupName varchar(100),@ForumID int) as
begin
	if @NntpForumID is null
		insert into yaf_NntpForum(NntpServerID,GroupName,ForumID,LastMessageNo,LastUpdate)
		values(@NntpServerID,@GroupName,@ForumID,0,getdate())
	else
		update yaf_NntpForum set
			NntpServerID = @NntpServerID,
			GroupName = @GroupName,
			ForumID = @ForumID
		where NntpForumID = @NntpForumID
end
GO

-- NNTP END

if not exists(select * from syscolumns where id=object_id('yaf_User') and name='Suspended')
	alter table yaf_User add Suspended datetime null
GO

if exists (select * from sysobjects where id = object_id(N'yaf_user_suspend') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_user_suspend
GO

create procedure yaf_user_suspend(@UserID int,@Suspend datetime=null) as
begin
	update yaf_User set Suspended = @Suspend where UserID=@UserID
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_pageload') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_pageload
GO

create procedure yaf_pageload(
	@SessionID	varchar(24),
	@User		varchar(50),
	@IP			varchar(15),
	@Location	varchar(50),
	@Browser	varchar(50),
	@Platform	varchar(50),
	@CategoryID	int = null,
	@ForumID	int = null,
	@TopicID	int = null,
	@MessageID	int = null
) as
begin
	declare @UserID int
	if @User is null or @User='' 
		select @UserID = a.UserID from yaf_User a,yaf_UserGroup b,yaf_Group c where a.UserID=b.UserID and b.GroupID=c.GroupID and c.IsGuest=1
	else
		select @UserID = UserID from yaf_User where Name = @User
	-- Check valid ForumID
	if @ForumID is not null and not exists(select 1 from yaf_Forum where ForumID=@ForumID) begin
		set @ForumID = null
	end
	-- Check valid CategoryID
	if @CategoryID is not null and not exists(select 1 from yaf_Category where CategoryID=@CategoryID) begin
		set @CategoryID = null
	end
	-- Check valid MessageID
	if @MessageID is not null and not exists(select 1 from yaf_Message where MessageID=@MessageID) begin
		set @MessageID = null
	end
	-- Check valid TopicID
	if @TopicID is not null and not exists(select 1 from yaf_Topic where TopicID=@TopicID) begin
		set @TopicID = null
	end

	-- update last visit
	update yaf_User set 
		LastVisit = getdate(),
		IP = @IP
	where UserID = @UserID
	-- find missing ForumID/TopicID
	if @MessageID is not null begin
		select
			@CategoryID = c.CategoryID,
			@ForumID = b.ForumID,
			@TopicID = b.TopicID
		from
			yaf_Message a,
			yaf_Topic b,
			yaf_Forum c
		where
			a.MessageID = @MessageID and
			b.TopicID = a.TopicID and
			c.ForumID = b.ForumID
	end
	else if @TopicID is not null begin
		select 
			@CategoryID = b.CategoryID,
			@ForumID = a.ForumID 
		from 
			yaf_Topic a,
			yaf_Forum b
		where 
			a.TopicID = @TopicID and
			b.ForumID = a.ForumID
	end
	else if @ForumID is not null begin
		select
			@CategoryID = a.CategoryID
		from
			yaf_Forum a
		where
			a.ForumID = @ForumID
	end
	-- update active
	if @UserID is not null begin
		if exists(select 1 from yaf_Active where SessionID = @SessionID)
		begin
			update yaf_Active set
				UserID = @UserID,
				IP = @IP,
				LastActive = getdate(),
				Location = @Location,
				ForumID = @ForumID,
				TopicID = @TopicID,
				Browser = @Browser,
				Platform = @Platform
			where SessionID = @SessionID
		end
		else begin
			insert into yaf_Active(SessionID,UserID,IP,Login,LastActive,Location,ForumID,TopicID,Browser,Platform)
			values(@SessionID,@UserID,@IP,getdate(),getdate(),@Location,@ForumID,@TopicID,@Browser,@Platform)
		end
		-- remove duplicate users
		delete from yaf_Active where UserID=@UserID and SessionID<>@SessionID
	end
	-- return information
	select
		a.UserID,
		UserName			= a.Name,
		Suspended			= a.Suspended,
		ThemeFile			= a.ThemeFile,
		LanguageFile		= a.LanguageFile,
		IsAdmin				= (select count(1) from yaf_UserGroup x,yaf_Group y where x.UserID=a.UserID and x.GroupID=y.GroupID and y.IsAdmin<>0),
		IsGuest				= (select count(1) from yaf_UserGroup x,yaf_Group y where x.UserID=a.UserID and x.GroupID=y.GroupID and y.IsGuest<>0),
		IsForumModerator	= (select count(1) from yaf_UserGroup x,yaf_Group y where x.UserID=a.UserID and x.GroupID=y.GroupID and y.IsModerator<>0),
		IsModerator			= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ModeratorAccess<>0),
		ReadAccess			= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.ReadAccess<>0),
		PostAccess			= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.PostAccess<>0),
		ReplyAccess			= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.ReplyAccess<>0),
		PriorityAccess		= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.PriorityAccess<>0),
		PollAccess			= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.PollAccess<>0),
		VoteAccess			= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.VoteAccess<>0),
		ModeratorAccess		= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.ModeratorAccess<>0),
		EditAccess			= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.EditAccess<>0),
		DeleteAccess		= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.DeleteAccess<>0),
		UploadAccess		= (select count(1) from yaf_ForumAccess x,yaf_UserGroup y where y.UserID=a.UserID and x.GroupID=y.GroupID and x.ForumID=@ForumID and x.UploadAccess<>0),
		CategoryID			= @CategoryID,
		CategoryName		= (select Name from yaf_Category where CategoryID = @CategoryID),
		ForumID				= @ForumID,
		ForumName			= (select Name from yaf_Forum where ForumID = @ForumID),
		TopicID				= @TopicID,
		TopicName			= (select Topic from yaf_Topic where TopicID = @TopicID),
		TimeZoneUser		= a.TimeZone,
		TimeZoneForum		= s.TimeZone,
		BBName				= s.Name,
		SmtpServer			= s.SmtpServer,
		SmtpUserName		= s.SmtpUserName,
		SmtpUserPass		= s.SmtpUserPass,
		ForumEmail			= s.ForumEmail,
		EmailVerification	= s.EmailVerification,
		BlankLinks			= s.BlankLinks,
		ShowMoved			= s.ShowMoved,
		ShowGroups			= s.ShowGroups,
		AllowRichEdit		= s.AllowRichEdit,
		AllowUserTheme		= s.AllowUserTheme,
		AllowUserLanguage	= s.AllowUserLanguage,
		MailsPending		= (select count(1) from yaf_Mail),
		Incoming			= (select count(1) from yaf_PMessage where ToUserID=a.UserID and IsRead=0)
	from
		yaf_User a,
		yaf_System s
	where
		a.UserID = @UserID
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_user_find') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_user_find
GO

create procedure yaf_user_find(@Filter bit,@UserName varchar(50)=null,@Email varchar(50)=null) as
begin
	if @Filter<>0
	begin
		if @UserName is not null
			set @UserName = '%' + @UserName + '%'

		select 
			a.*,
			IsGuest = (select count(1) from yaf_UserGroup x,yaf_Group y where x.UserID=a.UserID and x.GroupID=y.GroupID and y.IsGuest<>0)
		from 
			yaf_User a
		where 
			(@UserName is not null and a.Name like @UserName) or (@Email is not null and Email like @Email)
		order by
			a.Name
	end else
	begin
		select 
			a.UserID,
			IsGuest = (select count(1) from yaf_UserGroup x,yaf_Group y where x.UserID=a.UserID and x.GroupID=y.GroupID and y.IsGuest<>0)
		from 
			yaf_User a
		where 
			(@UserName is not null and a.Name=@UserName) or (@Email is not null and Email=@Email)
	end
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_pmessage_save') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_pmessage_save
GO

create procedure yaf_pmessage_save(
	@FromUserID	int,
	@ToUserID	int,
	@Subject	varchar(100),
	@Body		text
) as
begin
	insert into yaf_PMessage(FromUserID,ToUserID,Created,Subject,Body,IsRead)
	values(@FromUserID,@ToUserID,getdate(),@Subject,@Body,0)
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_pmessage_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_pmessage_info
GO

create procedure yaf_pmessage_info as
begin
	select
		NumRead	= (select count(1) from yaf_PMessage where IsRead<>0),
		NumUnread = (select count(1) from yaf_PMessage where IsRead=0),
		NumTotal = (select count(1) from yaf_PMessage)
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_pmessage_prune') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_pmessage_prune
GO

create procedure yaf_pmessage_prune(@DaysRead int,@DaysUnread int) as
begin
	delete from yaf_PMessage
	where IsRead<>0
	and datediff(dd,Created,getdate())>@DaysRead

	delete from yaf_PMessage
	where IsRead=0
	and datediff(dd,Created,getdate())>@DaysUnread
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_system_save') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_system_save
GO

create procedure yaf_system_save(
	@Name				varchar(50),
	@TimeZone			int,
	@SmtpServer			varchar(50),
	@SmtpUserName		varchar(50)=null,
	@SmtpUserPass		varchar(50)=null,
	@ForumEmail			varchar(50),
	@EmailVerification	bit,
	@ShowMoved			bit,
	@BlankLinks			bit,
	@ShowGroups			bit,
	@AvatarWidth		int,
	@AvatarHeight		int,
	@AvatarUpload		bit,
	@AvatarRemote		bit,
	@AvatarSize			int=null,
	@AllowRichEdit		bit,
	@AllowUserTheme		bit,
	@AllowUserLanguage	bit
) as
begin
	update yaf_System set
		Name = @Name,
		TimeZone = @TimeZone,
		SmtpServer = @SmtpServer,
		SmtpUserName = @SmtpUserName,
		SmtpUserPass = @SmtpUserPass,
		ForumEmail = @ForumEmail,
		EmailVerification = @EmailVerification,
		ShowMoved = @ShowMoved,
		BlankLinks = @BlankLinks,
		ShowGroups = @ShowGroups,
		AvatarWidth = @AvatarWidth,
		AvatarHeight = @AvatarHeight,
		AvatarUpload = @AvatarUpload,
		AvatarRemote = @AvatarRemote,
		AvatarSize = @AvatarSize,
		AllowRichEdit = @AllowRichEdit,
		AllowUserTheme = @AllowUserTheme,
		AllowUserLanguage = @AllowUserLanguage
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_system_initialize') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_system_initialize
GO

create procedure yaf_system_initialize(
	@Name		varchar(50),
	@TimeZone	int,
	@ForumEmail	varchar(50),
	@SmtpServer	varchar(50),
	@User		varchar(50),
	@UserEmail	varchar(50),
	@Password	varchar(32)
) as 
begin
	declare @GroupID int
	declare @RankID int
	declare @UserID int

	insert into yaf_System(SystemID,Version,VersionName,Name,TimeZone,SmtpServer,ForumEmail,AvatarWidth,AvatarHeight,AvatarUpload,AvatarRemote,EmailVerification,ShowMoved,BlankLinks,ShowGroups,AllowRichEdit,AllowUserTheme,AllowUserLanguage)
	values(1,1,'0.7.0',@Name,@TimeZone,@SmtpServer,@ForumEmail,50,80,0,0,1,1,0,1,1,0,0)

	insert into yaf_Rank(Name,IsStart,IsLadder)
	values('Administration',0,0)
	set @RankID = @@IDENTITY

	insert into yaf_Group(Name,IsAdmin,IsGuest,IsStart,IsModerator)
	values('Administration',1,0,0,0)
	set @GroupID = @@IDENTITY

	insert into yaf_User(RankID,Name,Password,Joined,LastVisit,NumPosts,TimeZone,Approved,Email)
	values(@RankID,@User,@Password,getdate(),getdate(),0,@TimeZone,1,@UserEmail)
	set @UserID = @@IDENTITY

	insert into yaf_UserGroup(UserID,GroupID) values(@UserID,@GroupID)

	insert into yaf_Rank(Name,IsStart,IsLadder)
	values('Guest',0,0)
	set @RankID = @@IDENTITY

	insert into yaf_Group(Name,IsAdmin,IsGuest,IsStart,IsModerator)
	values('Guest',0,1,0,0)
	set @GroupID = @@IDENTITY

	insert into yaf_User(RankID,Name,Password,Joined,LastVisit,NumPosts,TimeZone,Approved,Email)
	values(@RankID,'Guest','na',getdate(),getdate(),0,@TimeZone,1,@ForumEmail)
	set @UserID = @@IDENTITY

	insert into yaf_UserGroup(UserID,GroupID) values(@UserID,@GroupID)

	-- users starts as Newbie
	insert into yaf_Rank(Name,IsStart,IsLadder,MinPosts)
	values('Newbie',1,1,0)

	-- advances to Member
	insert into yaf_Rank(Name,IsStart,IsLadder,MinPosts)
	values('Member',0,1,10)

	-- and ends up as Advanced Member
	insert into yaf_Rank(Name,IsStart,IsLadder,MinPosts)
	values('Advanced Member',0,1,30)

	insert into yaf_Group(Name,IsAdmin,IsGuest,IsStart,IsModerator)
	values('Member',0,0,1,0)
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_topic_move') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_topic_move
GO

create procedure yaf_topic_move(@TopicID int,@ForumID int,@ShowMoved bit) as
begin
	declare @OldForumID int

	select @OldForumID = ForumID from yaf_Topic where TopicID = @TopicID

	if @ShowMoved<>0 begin
		-- create a moved message
		insert into yaf_Topic(ForumID,UserID,UserName,Posted,Topic,Views,IsLocked,Priority,PollID,TopicMovedID,LastPosted)
		select ForumID,UserID,UserName,Posted,Topic,0,IsLocked,Priority,PollID,@TopicID,LastPosted
		from yaf_Topic where TopicID = @TopicID
	end

	-- move the topic
	update yaf_Topic set ForumID = @ForumID where TopicID = @TopicID

	-- update last posts
	exec yaf_topic_updatelastpost @OldForumID
	exec yaf_topic_updatelastpost @ForumID
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_topic_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_topic_list
GO

CREATE  procedure yaf_topic_list(@ForumID int,@UserID int,@Announcement smallint,@Date datetime=null) as
begin
	select
		c.ForumID,
		c.TopicID,
		LinkTopicID = IsNull(c.TopicMovedID,c.TopicID),
		c.TopicMovedID,
		Subject = c.Topic,
		c.UserID,
		Starter = IsNull(c.UserName,b.Name),
		Replies = (select count(1) from yaf_Message x where x.TopicID=c.TopicID) - 1,
		Views = c.Views,
		LastPosted = c.LastPosted,
		LastUserID = c.LastUserID,
		LastUserName = IsNull(c.LastUserName,(select Name from yaf_User x where x.UserID=c.LastUserID)),
		LastMessageID = c.LastMessageID,
		LastTopicID = c.TopicID,
		c.IsLocked,
		c.Priority,
		c.PollID,
		PostAccess	= (select count(1) from yaf_UserGroup x,yaf_ForumAccess y where x.UserID=g.UserID and y.GroupID=x.GroupID and y.PostAccess<>0),
		ReplyAccess	= (select count(1) from yaf_UserGroup x,yaf_ForumAccess y where x.UserID=g.UserID and y.GroupID=x.GroupID and y.ReplyAccess<>0),
		ReadAccess	= (select count(1) from yaf_UserGroup x,yaf_ForumAccess y where x.UserID=g.UserID and y.GroupID=x.GroupID and y.ReadAccess<>0)
	from
		yaf_Topic c,
		yaf_User b,
		yaf_Forum d,
		yaf_User g
	where
		c.ForumID = @ForumID and
		b.UserID = c.UserID and
		(@Date is null or c.Posted>=@Date or Priority>0) and
		d.ForumID = c.ForumID and
		g.UserID = @UserID and
		((@Announcement=1 and c.Priority=2) or (@Announcement=0 and c.Priority<>2) or (@Announcement<0)) and
		((c.TopicMovedID is not null) or exists(select 1 from yaf_Message x where x.TopicID=c.TopicID and x.Approved<>0))
	order by
		Priority desc,
		LastPosted desc
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_topic_updatelastpost') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_topic_updatelastpost
GO

create procedure yaf_topic_updatelastpost(@ForumID int=null,@TopicID int=null) as
begin
	-- this really needs some work...
	if @ForumID is not null
		update yaf_Forum set
			LastPosted = (select top 1 y.Posted from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc),
			LastTopicID = (select top 1 y.TopicID from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc),
			LastMessageID = (select top 1 y.MessageID from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc),
			LastUserID = (select top 1 y.UserID from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc),
			LastUserName = (select top 1 y.UserName from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc)
		where ForumID = @ForumID
	else if @TopicID is not null
		update yaf_Topic set
			LastPosted = (select top 1 x.Posted from yaf_Message x where x.TopicID=yaf_Topic.TopicID and x.Approved<>0 order by Posted desc),
			LastMessageID = (select top 1 x.MessageID from yaf_Message x where x.TopicID=yaf_Topic.TopicID and x.Approved<>0 order by Posted desc),
			LastUserID = (select top 1 x.UserID from yaf_Message x where x.TopicID=yaf_Topic.TopicID and x.Approved<>0 order by Posted desc),
			LastUserName = (select top 1 x.UserName from yaf_Message x where x.TopicID=yaf_Topic.TopicID and x.Approved<>0 order by Posted desc)
		where TopicID = @TopicID
	else begin
		update yaf_Topic set
			LastPosted = (select top 1 x.Posted from yaf_Message x where x.TopicID=yaf_Topic.TopicID and x.Approved<>0 order by Posted desc),
			LastMessageID = (select top 1 x.MessageID from yaf_Message x where x.TopicID=yaf_Topic.TopicID and x.Approved<>0 order by Posted desc),
			LastUserID = (select top 1 x.UserID from yaf_Message x where x.TopicID=yaf_Topic.TopicID and x.Approved<>0 order by Posted desc),
			LastUserName = (select top 1 x.UserName from yaf_Message x where x.TopicID=yaf_Topic.TopicID and x.Approved<>0 order by Posted desc)
		where TopicMovedID is null
		update yaf_Forum set
			LastPosted = (select top 1 y.Posted from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc),
			LastTopicID = (select top 1 y.TopicID from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc),
			LastMessageID = (select top 1 y.MessageID from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc),
			LastUserID = (select top 1 y.UserID from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc),
			LastUserName = (select top 1 y.UserName from yaf_Topic x,yaf_Message y where x.ForumID=yaf_Forum.ForumID and y.TopicID=x.TopicID and y.Approved<>0 order by y.Posted desc)
	end
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_watchforum_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_watchforum_list
GO

create procedure yaf_watchforum_list(@UserID int) as
begin
	select
		a.*,
		ForumName = b.Name,
		Messages = (select count(1) from yaf_Topic x, yaf_Message y where x.ForumID=a.ForumID and y.TopicID=x.TopicID),
		Topics = (select count(1) from yaf_Topic x where x.ForumID=a.ForumID and x.TopicMovedID is null),
		b.LastPosted,
		b.LastMessageID,
		LastTopicID = (select TopicID from yaf_Message x where x.MessageID=b.LastMessageID),
		b.LastUserID,
		LastUserName = IsNull(b.LastUserName,(select Name from yaf_User x where x.UserID=b.LastUserID))
	from
		yaf_WatchForum a,
		yaf_Forum b
	where
		a.UserID = @UserID and
		b.ForumID = a.ForumID
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_user_save') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_user_save
GO

create procedure yaf_user_save(
	@UserID			int,
	@UserName		varchar(50) = null,
	@Password		varchar(32) = null,
	@Email			varchar(50) = null,
	@Hash			varchar(32) = null,
	@Location		varchar(50),
	@HomePage		varchar(50),
	@TimeZone		int,
	@Avatar			varchar(100) = null,
	@LanguageFile	varchar(50) = null,
	@ThemeFile		varchar(50) = null,
	@Approved		bit = null
) as
begin
	declare @RankID int

	if @Location is not null and @Location = '' set @Location = null
	if @HomePage is not null and @HomePage = '' set @HomePage = null
	if @Avatar is not null and @Avatar = '' set @Avatar = null

	if @UserID is null or @UserID<1 begin
		if @Email = '' set @Email = null
		
		select @RankID = RankID from yaf_Rank where IsStart<>0
		
		insert into yaf_User(RankID,Name,Password,Email,Joined,LastVisit,NumPosts,Approved,Location,HomePage,TimeZone,Avatar) 
		values(@RankID,@UserName,@Password,@Email,getdate(),getdate(),0,@Approved,@Location,@HomePage,@TimeZone,@Avatar)
	
		set @UserID = @@IDENTITY

		insert into yaf_UserGroup(UserID,GroupID) select @UserID,GroupID from yaf_Group where IsStart<>0
		
		if @Hash is not null and @Hash <> '' and @Approved=0 begin
			insert into yaf_CheckEmail(UserID,Email,Created,Hash)
			values(@UserID,@Email,getdate(),@Hash)	
		end
	end
	else begin
		update yaf_User set
			Location = @Location,
			HomePage = @HomePage,
			TimeZone = @TimeZone,
			Avatar = @Avatar,
			LanguageFile = @LanguageFile,
			ThemeFile = @ThemeFile
		where UserID = @UserID
		
		if @Email is not null
			update yaf_User set Email = @Email where UserID = @UserID
	end
end
GO

if exists (select * from sysobjects where id = object_id(N'yaf_attachment_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_attachment_list
GO

create procedure yaf_attachment_list(@MessageID int=null) as begin
	if @MessageID is not null
		select * from yaf_Attachment where MessageID=@MessageID
	else
		select 
			a.*,
			Posted		= b.Posted,
			ForumID		= d.ForumID,
			ForumName	= d.Name,
			TopicID		= c.TopicID,
			TopicName	= c.Topic
		from 
			yaf_Attachment a,
			yaf_Message b,
			yaf_Topic c,
			yaf_Forum d
		where
			b.MessageID = a.MessageID and
			c.TopicID = b.TopicID and
			d.ForumID = c.ForumID
		order by
			d.Name,
			c.Topic,
			b.Posted
end
go

if exists (select * from sysobjects where id = object_id(N'yaf_attachment_delete') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_attachment_delete
GO

create procedure yaf_attachment_delete(@AttachmentID int) as begin
	delete from yaf_Attachment where AttachmentID=@AttachmentID
end
go

if exists (select * from sysobjects where id = object_id(N'yaf_user_delete') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure yaf_user_delete
GO

create procedure yaf_user_delete(@UserID int) as
begin
	declare @GuestUserID int
	declare @UserName varchar(50)

	select @UserName = Name from yaf_User where UserID=@UserID

	select top 1
		@GuestUserID = a.UserID
	from
		yaf_User a,
		yaf_UserGroup b,
		yaf_Group c
	where
		b.UserID = a.UserID and
		b.GroupID = c.GroupID and
		c.IsGuest<>0

	update yaf_Message set UserName=@UserName,UserID=@GuestUserID where UserID=@UserID
	update yaf_Topic set UserName=@UserName,UserID=@GuestUserID where UserID=@UserID
	update yaf_Topic set LastUserName=@UserName,LastUserID=@GuestUserID where LastUserID=@UserID
	update yaf_Forum set LastUserName=@UserName,LastUserID=@GuestUserID where LastUserID=@UserID

	delete from yaf_PMessage where FromUserID=@UserID or ToUserID=@UserID
	delete from yaf_CheckEmail where UserID = @UserID
	delete from yaf_WatchTopic where UserID = @UserID
	delete from yaf_WatchForum where UserID = @UserID
	delete from yaf_UserGroup where UserID = @UserID
	delete from yaf_User where UserID = @UserID
end
GO
